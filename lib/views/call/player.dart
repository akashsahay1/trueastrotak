import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../controllers/history_controller.dart';

class Player extends StatefulWidget {
  final String sid;
  const Player({super.key, required this.sid});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final historyController = Get.find<HistoryController>();
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoUrl = "https://s3-ap-south-1.amazonaws.com/astroway/${widget.sid}_${historyController.callHistoryListById[0].channelName}.m3u8";

      // Updated to use networkUrl with configuration
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        // Configure for HLS streaming
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true, allowBackgroundPlayback: false),
      );

      // Listen for player initialization
      await _videoPlayerController.initialize();

      // Listen for errors during playback
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.hasError) {
          setState(() {
            _hasError = true;
          });
        }
      });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
        errorBuilder: (context, errorMessage) {
          return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
        },
        materialProgressColors: ChewieProgressColors(playedColor: Colors.red, handleColor: Colors.red, backgroundColor: Colors.grey, bufferedColor: Colors.grey.shade700),
        placeholder: Center(child: Text("Loading video...", style: TextStyle(color: Colors.white, fontSize: 16.sp))),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing player: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      backgroundColor: Colors.grey.shade300,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black),
                alignment: Alignment.center,
                child:
                    _hasError
                        ? Center(child: Text("Error loading video", style: TextStyle(color: Colors.white, fontSize: 16.sp)))
                        : _isLoading
                        ? Center(child: Text("Loading video...", style: TextStyle(color: Colors.white, fontSize: 16.sp)))
                        : AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: _chewieController)),
              ),
              if (!_isLoading && !_hasError) Positioned(child: Icon(Icons.music_video, color: Colors.white.withValues(alpha: 0.7), size: 30.sp)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
