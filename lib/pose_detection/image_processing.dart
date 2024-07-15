import "dart:io";

import "package:flutter/services.dart";

import "package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart";

import "package:camera/camera.dart";

final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270
};

InputImage? inputImageFromCameraImage( CameraController cameraController, CameraImage image ) {
    final camera = cameraController.description;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if( Platform.isIOS ) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
        var rotationCompensation = _orientations[ cameraController.value.deviceOrientation ];
        if( rotationCompensation == null ) return null;
        if( camera.lensDirection == CameraLensDirection.front ) {
            rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
        } else {
            rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
        }
        rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if( rotation == null ) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if( format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;
    if( image.planes.length != 1 ) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
            size: Size( image.width.toDouble(), image.height.toDouble() ),
            rotation: rotation,
            format: format,
            bytesPerRow: plane.bytesPerRow
        )
    );
}