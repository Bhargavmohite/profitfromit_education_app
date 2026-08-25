import 'package:flutter/material.dart';
import 'package:webinar/common/common.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodVideoPlayerDev extends StatefulWidget {
  final String type;
  final String url;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const PodVideoPlayerDev(this.url, this.type, this.routeObserver, {super.key});

  @override
  State<PodVideoPlayerDev> createState() => _VimeoVideoPlayerState();
}

class _VimeoVideoPlayerState extends State<PodVideoPlayerDev> with RouteAware {
  // late final PodPlayerController? controller;
  // YoutubePlayerController? _playerController;

  YoutubePlayerController? _playerController;

  @override
  void initState() {
    debugPrint("video player url =======================> ${widget.url}");
    debugPrint("video player type =======================> ${widget.type}");

    if (widget.type == 'vimeo') {
      // controller = PodPlayerController(
      //   playVideoFrom: PlayVideoFrom.vimeo(
      //     widget.url,
      //     videoPlayerOptions: VideoPlayerOptions(
      //       allowBackgroundPlayback: true,
      //     ),
      //   ),
      //   podPlayerConfig: const PodPlayerConfig(
      //     autoPlay: true,
      //     isLooping: false,
      //     wakelockEnabled: true,
      //     videoQualityPriority: [720, 360],
      //   ),
      // );
      //
      // controller!.initialise();
    } else {
      if(widget.type == 'youtube') {
        String videoId = YoutubePlayer.convertUrlToId(widget.url) ?? "";
        _playerController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            mute: false,
            autoPlay: true,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );

      } else {
        // controller = PodPlayerController(
        //   playVideoFrom: PlayVideoFrom.network(widget.url),
        // )..initialise().then((value) {
        //   setState(() {});
        // }, onError: (e) {
        //   debugPrint("video player error ============> ${e.toString()}");
        // });
      }
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    // if(controller != null || controller!.isInitialised) {
    //   controller!.dispose();
    // }
    if(_playerController != null) {
      _playerController!.dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    if(_playerController != null) {
      _playerController!.pause();
    }
    super.deactivate();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {
    // final route = ModalRoute.of(context)?.settings.name;
    // if(controller != null || controller!.isInitialised) {
    //   controller!.pause();
    // }
    if(_playerController != null) {
      _playerController!.pause();
    }
  }

  @override
  void didPopNext() {
    // if(controller != null || controller!.isInitialised) {
    //   controller!.play();
    // }
    if(_playerController != null) {
      _playerController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: borderRadius(),
        child: SizedBox(
          width: double.infinity,
          child: YoutubePlayer(
            controller: _playerController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            topActions: <Widget>[
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _playerController!.metadata.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            onReady: () {

            },
            onEnded: (YoutubeMetaData data) {
              debugPrint("data ============> $data");
            },
          ),
        ),
      ),
    );
  }
}
