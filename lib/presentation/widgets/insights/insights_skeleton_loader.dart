import 'package:flutter/material.dart';

class InsightsSkeletonLoader extends StatefulWidget {
  const InsightsSkeletonLoader({super.key});

  @override
  State<InsightsSkeletonLoader> createState() => _InsightsSkeletonLoaderState();
}

class _InsightsSkeletonLoaderState extends State<InsightsSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final shimmerColor = Color.lerp(
          const Color(0xFFF1F5F9),
          const Color(0xFFE2E8F0),
          _animation.value,
        )!;

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Synthesizing Insights...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card 1 Skeleton: Spent This Month (Full Width)
                  _SkeletonCard(
                    shimmerColor: shimmerColor,
                    height: 145,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(width: 110, height: 13, color: shimmerColor),
                        const SizedBox(height: 10),
                        _Bone(width: 160, height: 26, color: shimmerColor),
                        const SizedBox(height: 6),
                        _Bone(width: 90, height: 11, color: shimmerColor),
                        const Spacer(),
                        _Bone(
                          width: double.infinity,
                          height: 8,
                          color: shimmerColor,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            4,
                            (_) => _Bone(
                              width: 50,
                              height: 10,
                              color: shimmerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cards 2 & 3 Skeleton: Dual Column Row
                  Row(
                    children: [
                      // Card 2 Skeleton: Net Cash Flow
                      Expanded(
                        child: _SkeletonCard(
                          shimmerColor: shimmerColor,
                          height: 135,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bone(width: 85, height: 12, color: shimmerColor),
                              const SizedBox(height: 10),
                              _Bone(
                                width: 100,
                                height: 22,
                                color: shimmerColor,
                              ),
                              const Spacer(),
                              _Bone(
                                width: double.infinity,
                                height: 8,
                                color: shimmerColor,
                              ),
                              const SizedBox(height: 8),
                              _Bone(width: 70, height: 8, color: shimmerColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Card 3 Skeleton: Profit Earned
                      Expanded(
                        child: _SkeletonCard(
                          shimmerColor: shimmerColor,
                          height: 135,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Bone(width: 80, height: 12, color: shimmerColor),
                              const SizedBox(height: 10),
                              _Bone(width: 95, height: 22, color: shimmerColor),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _Bone(
                                        width: 60,
                                        height: 9,
                                        color: shimmerColor,
                                      ),
                                      const SizedBox(height: 6),
                                      _Bone(
                                        width: 50,
                                        height: 9,
                                        color: shimmerColor,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: shimmerColor,
                                        width: 5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Card 4 Skeleton: Assets (Full Width)
                  _SkeletonCard(
                    shimmerColor: shimmerColor,
                    height: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Bone(width: 70, height: 13, color: shimmerColor),
                        const SizedBox(height: 10),
                        _Bone(width: 170, height: 26, color: shimmerColor),
                        const Spacer(),
                        _Bone(
                          width: double.infinity,
                          height: 8,
                          color: shimmerColor,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _Bone(width: 60, height: 10, color: shimmerColor),
                            const SizedBox(width: 20),
                            _Bone(width: 60, height: 10, color: shimmerColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({
    required this.child,
    required this.height,
    required this.shimmerColor,
  });

  final Widget child;
  final double height;
  final Color shimmerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6347D1).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
