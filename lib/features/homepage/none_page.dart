import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Potato/core/state/video_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'dart:async';

class NonePage extends StatefulWidget {
  const NonePage({super.key});

  @override
  _NonePageState createState() => _NonePageState();
}

class _NonePageState extends State<NonePage> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showAnimation = false;
      });
    });
  }

  void _showAnnouncementDialog(BuildContext context, String title, String content, String date) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pinkAccent.withOpacity(0.8),
                Colors.lightBlueAccent.withOpacity(0.8),
                Colors.yellowAccent.withOpacity(0.8),
                Colors.greenAccent.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(0, 6),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontFamily: 'Lato',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: Chip(
                  label: Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  avatar: Icon(
                    Icons.calendar_today,
                    color: Colors.blueGrey,
                  ),
                  backgroundColor: Colors.white.withOpacity(0.8),
                  elevation: 5.0,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  child: Text(
                    '关闭',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _showAnimation
                ? AnimatedBackground()
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purpleAccent,
                          Colors.blue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Shimmer.fromColors(
                baseColor: Colors.white,
                highlightColor: Colors.pinkAccent,
                child: Text(
                  '公告栏',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monoton',
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(
                        offset: Offset(3.0, 3.0),
                        blurRadius: 5.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
            child: Consumer<VideoState>(
              builder: (context, videoState, child) {
                if (videoState.isLoading) {
                  return Center(
                    child: Pulse(
                      infinite: true,
                      child: Icon(
                        Icons.hourglass_empty,
                        color: Colors.white.withOpacity(0.8),
                        size: 50,
                      ),
                    ),
                  );
                } else if (videoState.hasError) {
                  return Center(
                    child: FadeIn(
                      child: Text(
                        '加载公告信息失败',
                        style: TextStyle(color: Colors.redAccent, fontSize: 18),
                      ),
                    ),
                  );
                } else if (videoState.announcements.isEmpty) {
                  return Center(
                    child: FadeIn(
                      child: Text(
                        '暂无公告',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.only(top: 40),
                    itemCount: videoState.announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = videoState.announcements[index];
                      return GestureDetector(
                        onTap: () => _showAnnouncementDialog(
                          context,
                          announcement['title'],
                          announcement['content'],
                          announcement['date'],
                        ),
                        child: SlideInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: AnimatedContainer(
                            duration: const Duration(seconds: 2),
                            curve: Curves.fastOutSlowIn,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pinkAccent.withOpacity(0.8),
                                  Colors.lightBlueAccent.withOpacity(0.8),
                                  Colors.yellowAccent.withOpacity(0.8),
                                  Colors.greenAccent.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(0, 6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                if (_showAnimation)
                                  Positioned.fill(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.white.withOpacity(0.3),
                                      highlightColor: Colors.white.withOpacity(0.6),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(
                                          Icons.announcement,
                                          size: 100,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ZoomIn(
                                      child: Text(
                                        announcement['title'],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                          letterSpacing: 1.5,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 3.0,
                                              color: Colors.black45,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    FadeIn(
                                      delay: Duration(milliseconds: 300),
                                      child: Text(
                                        announcement['content'].length > 40
                                            ? announcement['content'].substring(0, 40) + '...'
                                            : announcement['content'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          fontFamily: 'Lato',
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: SlideInRight(
                                        duration: Duration(milliseconds: 800),
                                        curve: Curves.easeInOut,
                                        delay: Duration(milliseconds: 600),
                                        child: Chip(
                                          label: Text(
                                            announcement['date'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueGrey,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          avatar: Icon(
                                            Icons.calendar_today,
                                            color: Colors.blueGrey,
                                          ),
                                          backgroundColor: Colors.white.withOpacity(0.8),
                                          elevation: 5.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pinkAccent,
                  Colors.blueAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CircularParticle(
            awayRadius: 100,
            numberOfParticles: 50,
            speedOfParticles: 1.5,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            onTapAnimation: true,
            particleColor: Colors.white.withAlpha(150),
            awayAnimationDuration: Duration(milliseconds: 600),
            maxParticleSize: 8,
            isRandSize: true,
            isRandomColor: true,
            randColorList: [
              Colors.white.withAlpha(210),
              Colors.pinkAccent.withAlpha(210),
              Colors.lightBlueAccent.withAlpha(210),
              Colors.yellowAccent.withAlpha(210),
            ],
            awayAnimationCurve: Curves.easeInOutBack,
            enableHover: true,
            hoverColor: Colors.white,
            hoverRadius: 90,
            connectDots: true,
          ),
        ),
      ],
    );
  }
}
