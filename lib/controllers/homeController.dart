import 'package:trueastrotalk/controllers/bottomNavigationController.dart';
import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:trueastrotalk/model/Allstories.dart';
import 'package:trueastrotalk/model/app_review_model.dart';
import 'package:trueastrotalk/model/home_Model.dart';
import 'package:trueastrotalk/model/viewStories.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:trueastrotalk/model/home_Model.dart' as home_model;

import '../model/language.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

class HomeController extends GetxController {
  List<Language> lan = [];
  APIHelper apiHelper = APIHelper();
  var bannerList = <home_model.Banner>[];
  var blogList = <Blog>[];
  var astroNews = <AstrotalkInNews>[];
  var astrologyVideo = <AstrologyVideo>[];
  var clientReviews = <AppReviewModel>[];
  var viewSingleStory = <ViewStories>[];
  var allStories = <AllStories>[];
  var myOrders = <TopOrder>[];
  final material.TextEditingController feedbackController = material.TextEditingController();
  final SplashController splashController = Get.find<SplashController>();
  final BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
  material.PageController pageController = material.PageController().obs();
  int reviewChange = 0.obs();
  VideoPlayerController? videoPlayerController;
  VideoPlayerController? homeVideoPlayerController;
  YoutubePlayerController? youtubePlayerController;
  int pageIndex = 0;

  @override
  void onInit() async {
    _init();
    _initializeVideoPlayer();
    super.onInit();
  }

  void _initializeVideoPlayer() {
    try {
      final behindScenesUrl = global.getSystemFlagValueForLogin(global.systemFlagNameList.behindScenes);
      if (behindScenesUrl.isNotEmpty) {
        final videoUrl = '${global.imgBaseurl}$behindScenesUrl';
        videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
          ..initialize().then((_) {
            videoPlayerController!.pause();
            videoPlayerController!.setLooping(true);
            update();
          }).catchError((error) {
            debugPrint('Error initializing video player: $error');
          });
      } else {
        debugPrint('Behind scenes video URL not available');
      }
    } catch (e) {
      debugPrint('Exception in _initializeVideoPlayer: $e');
    }
  }

  _init() async {
    try {
      await Future.wait([
        //  getAllStories(),
        // getBanner(),
        // getBlog(),
        // getAstroNews(),
        getMyOrder(),
        // getAstrologyVideos(),
        getClientsTestimonals(),
      ]);
      FutureBuilder(
        future: getAstrologyVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('getAstrologyVideos error ${snapshot.error}');
            }
            debugPrint('getAstrologyVideos');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );
      FutureBuilder(
        future: getAstroNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('getAstroNews error ${snapshot.error}');
            }
            debugPrint('getAstroNews');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );
      FutureBuilder(
        future: getBlog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('error ${snapshot.error}');
            }
            debugPrint('getBlog');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );
      FutureBuilder(
        future: getAllStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('error ${snapshot.error}');
            }
            debugPrint('getAllStories');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );
      FutureBuilder(
        future: getBanner(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              debugPrint('getBanner error ${snapshot.error}');
            }
            debugPrint('getBanner');
            return const SizedBox();
          } else {
            return const SizedBox();
          }
        },
      );
      bottomNavigationController.astrologerList.clear();
      await bottomNavigationController.getAstrologerList(isLazyLoading: false);
    } catch (e) {
      print("Exception -Homecontroller init future.wait: $e");
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onBackPressed() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;

      global.showToast(message: 'Press again to exit', textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return Future.value(false);
    }
    return Future.value(true);
  }

  void playPauseVideo() {
    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
      update();
    } else {
      videoPlayerController!.play();
      update();
    }
  }

  void blogplayPauseVideo(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
      update();
    } else {
      controller.play();
      update();
    }
  }

  Future youtubPlay(String url) async {
    String? videoId;
    videoId = YoutubePlayerController.convertUrlToId(url);
    youtubePlayerController = YoutubePlayerController.fromVideoId(
      videoId: videoId!,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    update();
  }

  homeBlogVideo(String link) {
    homeVideoPlayerController = VideoPlayerController.networkUrl(Uri.parse('${global.imgBaseurl}$link'))
      ..initialize().then((_) {
        homeVideoPlayerController!.pause();
        homeVideoPlayerController!.setLooping(true);
        update();
      });
  }

  int selectedIndex = 0;
  updateLan(int index) {
    selectedIndex = index;
    lan[index].isSelected = true;
    update();
    for (int i = 0; i < lan.length; i++) {
      if (i == index) {
        continue;
      } else {
        lan[i].isSelected = false;
        update();
      }
    }
    update();
  }

  Future<void> updateLanIndex() async {
    global.sp = await SharedPreferences.getInstance();
    var currentLan = global.sp!.getString('currentLanguage') ?? 'en';
    for (int i = 0; i < lan.length; i++) {
      if (lan[i].lanCode == currentLan) {
        selectedIndex = i;
        lan[i].isSelected = true;
        update();
      } else {
        lan[i].isSelected = false;
        update();
      }
    }
    print(selectedIndex);
  }

  bool checkBannerValid({required DateTime startDate, required DateTime endDate}) {
    DateTime now = DateTime.now();
    // end date is after or today and sart date is before or today show add
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      return true;
    }
    return false;
  }

  bool isbannerloading = false;
  Future<void> getBanner() async {
    isbannerloading = true;
    update();
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeBanner().then((result) {
            if (result != null && result.status == "200") {
              bannerList = result.recordList ?? [];
              isbannerloading = false;
              update();
            } else {
              debugPrint('Failed to get banner: ${result?.status ?? "null response"}');
              bannerList.clear();
              isbannerloading = false;
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getHomeBanner: $error');
            bannerList.clear();
            isbannerloading = false;
            update();
          });
        }
      });
    } catch (e) {
      bannerList.clear();
      isbannerloading = false;
      update();
      debugPrint("Exception in getBanner: $e");
    }
  }

  Future<void> getBlog() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeBlog().then((result) {
            if (result != null && result.status == "200") {
              blogList = result.recordList ?? [];
              update();
            } else {
              debugPrint('Failed to get Blogs: ${result?.status ?? "null response"}');
              blogList.clear();
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getHomeBlog: $error');
            blogList.clear();
            update();
          });
        }
      });
    } catch (e) {
      blogList.clear();
      update();
      debugPrint("Exception in getBlog: $e");
    }
  }

  Future<void> getAstroNews() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroNews().then((result) {
            if (result != null && result.status == "200") {
              astroNews = result.recordList ?? [];
              update();
            } else {
              debugPrint('Failed to get astro news: ${result?.status ?? "null response"}');
              astroNews.clear();
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getAstroNews: $error');
            astroNews.clear();
            update();
          });
        }
      });
    } catch (e) {
      astroNews.clear();
      update();
      debugPrint("Exception in getAstroNews: $e");
    }
  }

  Future<void> getMyOrder() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeOrder().then((result) {
            if (result != null && result.status == "200") {
              myOrders = result.recordList ?? [];
              update();
            } else {
              debugPrint('Failed to get my orders: ${result?.status ?? "null response"}');
              myOrders.clear();
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getHomeOrder: $error');
            myOrders.clear();
            update();
          });
        }
      });
    } catch (e) {
      myOrders.clear();
      update();
      debugPrint("Exception in getMyOrder: $e");
    }
  }

  Future<void> getAstrologyVideos() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroVideos().then((result) {
            if (result != null && result.status == "200") {
              astrologyVideo = result.recordList ?? [];
              update();
            } else {
              debugPrint('Failed to get astrology videos: ${result?.status ?? "null response"}');
              astrologyVideo.clear();
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getAstroVideos: $error');
            astrologyVideo.clear();
            update();
          });
        }
      });
    } catch (e) {
      astrologyVideo.clear();
      update();
      debugPrint("Exception in getAstrologyVideos: $e");
    }
  }

  Future<void> getClientsTestimonals() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAppReview().then((result) {
            if (result.status == "200") {
              clientReviews = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
  }

  incrementBlogViewer(int id) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.viewerCount(id).then((result) {
            if (result.status == "200") {
              print('success');
            } else {
              global.showToast(message: 'Faild to increment blog viewer', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            }
          });
        }
      });
    } catch (e) {
      print("Exception in incrementBlogViewer:- " + e.toString());
    }
  }

  addFeedback(String review) async {
    var appReviewModel = {"appId": global.appId, "review": review};
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.addAppFeedback(appReviewModel).then((result) {
            if (result.status == "200") {
              feedbackController.text = '';

              global.showToast(message: 'Thank you!', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            } else {
              global.showToast(message: 'Failed to add feedback', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            }
          });
        }
      });
    } catch (e) {
      print("Exception in addFeedback():- " + e.toString());
    }
  }

  Future<void> getLanguages() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          global.showOnlyLoaderDialog(Get.context);
          await apiHelper.getLanguagesForMultiLanguage().then((result) {
            global.hideLoader();
            if (result.status == "200") {
              lan.addAll(result.recordList);
              update();
            } else {
              global.showToast(message: 'Failed to get language!', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            }
          });
        }
      });
    } catch (e) {
      print("Exception in getLanguages():- " + e.toString());
    }
  }

  Future<void> getAllStories() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAllStory().then((result) {
            if (result != null && result.status == "200") {
              allStories = result.recordList ?? [];
              update();
            } else {
              debugPrint('Failed to get all stories: ${result?.status ?? "null response"}');
              allStories.clear();
              update();
            }
          }).catchError((error) {
            debugPrint('API error in getAllStory: $error');
            allStories.clear();
            update();
          });
        }
      });
    } catch (e) {
      allStories.clear();
      update();
      debugPrint("Exception in getAllStories: $e");
    }
  }

  Future<void> getAstroStory(String astroId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroStory(astroId).then((result) {
            if (result.status == "200") {
              viewSingleStory = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.storyViewed(storyId).then((result) {
            if (result.status == "200") {
              update();
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  storyViewed:-" + e.toString());
    }
  }
}
