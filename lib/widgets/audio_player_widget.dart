import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.color = Colors.blue,
    this.viewOnly = false,
    this.showRemainingTime = true,
    this.playbackRate = 1.0,
  });

  final String audioUrl;
  final Color color;
  final bool viewOnly;
  final bool showRemainingTime;
  final double playbackRate;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer audioPlayer;
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool hasError = false;
  PlayerState? _lastPlayerState;

  @override
  void initState() {
    audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop); // Liberar recursos cuando no se usa

    _setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _setupListeners() {
    // Escuchar cambios en el estado del reproductor
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _lastPlayerState = state;
          isPlaying = state == PlayerState.playing;
          if (state == PlayerState.completed) {
            position = const Duration();
          }
        });
      }
    });

    // Escuchar cambios en la posición
    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => position = newPosition);
      }
    });

    // Escuchar cambios en la duración
    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => duration = newDuration);
      }
    });

    // Escuchar eventos de error (nueva forma)
    audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          position = duration;
          isPlaying = false;
        });
      }
    });
  }

  Future<void> _handleError(dynamic error) async {
    debugPrint('Error en el reproductor: $error');
    if (mounted) {
      setState(() {
        hasError = true;
        isLoading = false;
        isPlaying = false;
      });
    }
    await audioPlayer.stop();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '${twoDigits(duration.inHours)}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Future<void> seekToPosition(double seconds) async {
    try {
      final newPosition = Duration(seconds: seconds.toInt());
      await audioPlayer.seek(newPosition);

      // Solo reanudar si estaba reproduciendo antes del seek
      if (_lastPlayerState == PlayerState.playing) {
        await audioPlayer.resume();
      }
    } catch (e) {
      await _handleError(e);
    }
  }

  Future<void> togglePlayback() async {
    if (hasError) return;

    try {
      setState(() => isLoading = true);

      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        // Configurar velocidad de reproducción
        await audioPlayer.setPlaybackRate(widget.playbackRate);

        if (position.inSeconds >= duration.inSeconds - 1) {
          // Si está cerca del final, reiniciar
          await audioPlayer.seek(const Duration());
        }

        await audioPlayer.play(UrlSource(widget.audioUrl)).catchError(_handleError);
      }
    } catch (e) {
      await _handleError(e);
    } finally {
      if (mounted && !hasError) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildPlayerButton() {
    if (hasError) {
      return const Icon(Icons.error, color: Colors.red);
    }

    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Icon(
      isPlaying ? Icons.pause : Icons.play_arrow,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón de reproducción
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.orangeAccent,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: widget.viewOnly || hasError ? null : togglePlayback,
              icon: _buildPlayerButton(),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Barra de progreso
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Slider.adaptive(
                min: 0.0,
                value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                max: duration.inSeconds.toDouble(),
                onChanged: widget.viewOnly || hasError ? null : seekToPosition,
                activeColor: widget.color,
                inactiveColor: widget.color.withOpacity(0.3),
              ),
              if (duration.inMilliseconds > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 12.0,
                        ),
                      ),
                      if (widget.showRemainingTime)
                        Text(
                          '-${formatTime(duration - position)}',
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 12.0,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}