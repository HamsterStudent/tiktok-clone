import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tiktok_clone/constants/gaps.dart';
import 'package:tiktok_clone/constants/sizes.dart';
import 'package:tiktok_clone/features/videos/widgets/video_button.dart';
import 'package:tiktok_clone/features/videos/widgets/video_comments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPost extends StatefulWidget {
  final Function onVideoFinished;

  final int index;

  const VideoPost({
    super.key,
    required this.onVideoFinished,
    required this.index,
  });

  @override
  State<VideoPost> createState() => _VideoPostState();
}

// with키워드에 Mixin을 사용하면 해당 클래스의 메서드와 속성들을 전부 가져오겠다는 의미
class _VideoPostState extends State<VideoPost>
    with SingleTickerProviderStateMixin {
  final VideoPlayerController _videoPlayerController =
      VideoPlayerController.asset("assets/videos/video.mp4");
  final Duration _animationDuration = const Duration(milliseconds: 200);
  late final AnimationController _animatinoController;

  bool _isPaused = false;

  void _onVideoChange() {
    if (_videoPlayerController.value.isInitialized) {
      // 영상의 길이와 사옹자가 보고 있는 영상 내의 위치와 같다면
      if (_videoPlayerController.value.duration ==
          _videoPlayerController.value.position) {
        // onVideoFinished를 실행시켜라
        widget.onVideoFinished();
      }
    }
  }

  void _initVideoPlayer() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    // _videoPlayerController.play();
    setState(() {});
    _videoPlayerController.addListener(_onVideoChange);
  }

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();

    _animatinoController = AnimationController(
      // vsync : 위젯이 보이지 않을 땐 애니메이션이 작동되지 않도록 함
      // 사용하려면 SingleTickerProviderStateMixin을 추가해야 함
      // this를 넣는 이유 : 해당 애니메이션을 구동
      vsync: this,
      // 시작점
      lowerBound: 1.0,
      // 끝나는 점
      upperBound: 1.5,
      // 기본값
      value: 1.5,
      // 시간
      duration: _animationDuration,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction == 1 &&
        !_isPaused &&
        !_videoPlayerController.value.isPlaying) {
      _videoPlayerController.play();
    }
  }

  void _onTogglePause() {
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
      // reverse : upper -> lower
      _animatinoController.reverse();
    } else {
      _videoPlayerController.play();
      // forward : lower -> upper
      _animatinoController.forward();
    }
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _onCommentsTap(BuildContext context) async {
    if (_videoPlayerController.value.isPlaying) {
      _onTogglePause();
    }
    // 아래에 모달을 만들어주는 함수
    // await을 사용해 움직임 감지, 비디오가 또다시 자동으로 재생
    await showModalBottomSheet(
      context: context,
      builder: (context) => const VideoComments(),
      isScrollControlled: true,
    );

    _onTogglePause();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("${widget.index}"),
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        children: [
          Positioned.fill(
            child: _videoPlayerController.value.isInitialized
                ? VideoPlayer(_videoPlayerController)
                : Container(
                    color: Colors.black,
                  ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _onTogglePause,
            ),
          ),
          Positioned.fill(
            // 아이콘 클릭 이벤트 무시
            child: IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  // 애니메이션 controller의 변화를 감지
                  animation: _animatinoController,
                  // 함수. animationController의 값이 변할 때마다 실행됨
                  builder: (context, child) {
                    // Transform.scale위젯을 return
                    return Transform.scale(
                      // 최신값으로 갱신됨
                      scale: _animatinoController.value,
                      // child는 매개변수로 넘어오는 child를 그대로 넣음
                      child: child,
                    );
                  },
                  // 이 child가 builder의 child에 들어간다
                  child: AnimatedOpacity(
                    opacity: _isPaused ? 1 : 0,
                    duration: _animationDuration,
                    child: const FaIcon(
                      FontAwesomeIcons.play,
                      color: Colors.white,
                      size: Sizes.size52,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@Hamster",
                  style: TextStyle(
                    fontSize: Sizes.size20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gaps.v10,
                Text(
                  "data is a cute hamster that eating my house",
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: Column(
              children: [
                // CircleAvatar : 이미지가 들어 있는 원 제공
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  foregroundImage: NetworkImage(
                      "data:image/png;base64,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"),
                  child: Text("햄스터"),
                ),
                Gaps.v24,
                const VideoButton(
                  icon: FontAwesomeIcons.solidHeart,
                  text: "2.9M",
                ),
                Gaps.v24,
                GestureDetector(
                  onTap: () => _onCommentsTap(context),
                  child: const VideoButton(
                    icon: FontAwesomeIcons.solidComment,
                    text: "33K",
                  ),
                ),
                Gaps.v24,
                const VideoButton(
                  icon: FontAwesomeIcons.share,
                  text: "Share",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
