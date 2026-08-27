import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pure_live/recorder/ffmpeg/ffmpeg_command_builder.dart';

/// 契约回归：录制参数必须作为"纯净原生参数向量"交付（Process.run 直连，
/// 不再经过命令字符串二次解析），URL/请求头/路径不接收引号包裹。
void main() {
  test('recording passes signed URLs, headers and output paths as exact native arguments', () {
    final outputDir = '${Directory.systemTemp.path}${Platform.pathSeparator}Pure Live Records';
    final arguments = FFmpegCommandBuilder.buildRecordArguments(
      url: 'https://cdn.example/live.flv?token=a&expires=2',
      outputDir: outputDir,
      segmentTime: 600,
      preferBestStream: true,
      rwTimeout: 15,
      threadQueueSize: 1024,
      filePrefix: 'session-001',
      headers: const <String, String>{'user-agent': 'Pure Live Test UA', 'referer': 'https://example.test/room/1'},
    );

    expect(_valueAfter(arguments, '-i'), 'https://cdn.example/live.flv?token=a&expires=2');
    expect(_valuesAfter(arguments, '-map'), <String>['0:v:0?', '0:a:0?']);
    expect(_valueAfter(arguments, '-user_agent'), 'Pure Live Test UA');
    expect(_valueAfter(arguments, '-headers'), 'referer: https://example.test/room/1\r\n');
    expect(arguments.last, '$outputDir${Platform.pathSeparator}session-001_%Y%m%d_%H%M%S.ts');
    expect(_valueAfter(arguments, '-reconnect'), '1');
    expect(_valueAfter(arguments, '-reconnect_streamed'), '1');
    expect(_valueAfter(arguments, '-reconnect_delay_max'), '10');
    expect(_valueAfter(arguments, '-reconnect_at_eof'), '1');
    expect(arguments, isNot(contains('-tls_verify')));
    expect(arguments.any((argument) => argument.startsWith('"') || argument.endsWith('"')), isFalse);
  });

  test('recording applies generic reconnect options and clamps native values', () {
    final udp = FFmpegCommandBuilder.buildRecordArguments(
      url: 'udp://239.0.0.1:1234',
      outputDir: Directory.systemTemp.path,
      segmentTime: 60,
      preferBestStream: false,
      rwTimeout: 12,
      threadQueueSize: 999999,
    );

    expect(_valueAfter(udp, '-thread_queue_size'), '999999');
    expect(_valueAfter(udp, '-seekable'), '1');
    expect(_valueAfter(udp, '-reconnect'), '1');
    expect(_valueAfter(udp, '-protocol_whitelist'), isNotEmpty);
  });

  test('header sanitizing keeps headers as raw values with one user-agent argument', () {
    final arguments = FFmpegCommandBuilder.buildRecordArguments(
      url: 'https://cdn.example/live.flv',
      outputDir: Directory.systemTemp.path,
      segmentTime: 60,
      preferBestStream: true,
      rwTimeout: 15,
      threadQueueSize: 1024,
      headers: const <String, String>{
        'User-Agent': 'Recorder UA',
        'Referer': 'https://example.test/\r\nCookie: injected',
        'Bad Header': 'ignored',
      },
    );

    expect(_valueAfter(arguments, '-user_agent'), 'Recorder UA');
    expect(
      _valueAfter(arguments, '-headers'),
      'Referer: https://example.test/\r\nCookie: injected\r\nBad Header: ignored\r\n',
    );
    expect(arguments.where((argument) => argument == '-user_agent'), hasLength(1));
    // 请求头作为原生参数向量传递（不再经过命令字符串二次解析），CRLF 内容
    // 不会成为命令行注入；user-agent 只允许出现一次且被移出 -headers。
    expect(_valueAfter(arguments, '-headers'), isNot(contains('User-Agent')));
  });

  test('audio relay preserves a signed input URL as one argument', () {
    final arguments = FFmpegCommandBuilder.buildAudioStreamArguments(
      remoteStreamUrl: 'https://cdn.example/audio.m3u8?token=a&expires=2',
      port: 19090,
    );

    expect(_valueAfter(arguments, '-i'), 'https://cdn.example/audio.m3u8?token=a&expires=2');
    expect(arguments, isNot(contains('-tls_verify')));
  });

  test('display formatting joins the native argument vector without quoting', () {
    final arguments = <String>['-i', 'https://cdn.example/live.flv?a=1&b=2', 'C:\\Pure Live\\out.ts'];
    final formatted = FFmpegCommandBuilder.formatArguments(arguments);

    expect(formatted, '-i https://cdn.example/live.flv?a=1&b=2 C:\\Pure Live\\out.ts');
    expect(arguments, <String>['-i', 'https://cdn.example/live.flv?a=1&b=2', 'C:\\Pure Live\\out.ts']);
  });
}

String _valueAfter(List<String> arguments, String option) {
  final index = arguments.indexOf(option);
  expect(index, greaterThanOrEqualTo(0), reason: option);
  expect(index + 1, lessThan(arguments.length), reason: option);
  return arguments[index + 1];
}

List<String> _valuesAfter(List<String> arguments, String option) {
  final values = <String>[];
  for (var index = 0; index < arguments.length - 1; index++) {
    if (arguments[index] == option) values.add(arguments[index + 1]);
  }
  return values;
}
