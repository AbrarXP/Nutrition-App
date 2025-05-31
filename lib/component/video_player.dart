import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Ganti nama widget:
class CustomVideoPlayer extends StatefulWidget {
  final String url;

  const CustomVideoPlayer(this.url, {super.key});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.url)
      ..initialize().then((_) {
        setState(() {
          _isReady = true;
        });
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isReady
        ? SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller), // <-- yang ini tetap
              ),
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
