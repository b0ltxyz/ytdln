import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';


void main() {

initializeYtdln();
print('Enter a playlist url: ');
String url = stdin.readLineSync() ?? 'exit';
download(url);

  
}



void initializeYtdln() {
  Directory('downloads').createSync(); 
}

Future<void> download(String url) async {
  if (url == 'exit') {
    exit(-1);
  }
  final yt = YoutubeExplode();
  final playlist = await yt.playlists.get(url);
  await for (var video in yt.playlists.getVideos(playlist.id)) {
  var manifest = await yt.videos.streamsClient.getManifest(video.id);
  var streams = manifest.audioOnly;
  var audio = streams.first;
  var audioStream = yt.videos.streamsClient.get(audio);
  var fileName = '${video.title}.mp3'
      .replaceAll(r'\', '')
      .replaceAll('/', '')
      .replaceAll('*', '')
      .replaceAll('?', '')
      .replaceAll('"', '')
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('|', '');
  var file = File('downloads/$fileName');
  var output = file.openWrite(mode: FileMode.writeOnlyAppend);
  var len = audio.size.totalBytes;
  var count = 0;
  var msg = 'Downloading: ${video.title}';
  stdout.writeln(msg);
  await for (final data in audioStream) {
    count += data.length;
    var progress = ((count / len) * 100).ceil();
    if (progress % 10 == 0) {
      print ("Progress: %$progress");
    }
    output.add(data);
  }
  await output.close();
  
  }
  print("All downloads has completed.");
  
  
}
