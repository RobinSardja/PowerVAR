import "dart:io";
import "dart:ui";

import "package:google_mlkit_commons/google_mlkit_commons.dart";

import "package:camera/camera.dart";

double translateX(
    double x,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection
) {
    final divisor = Platform.isIOS ? imageSize.width : imageSize.height;
    double temp = x * canvasSize.width;

    switch( rotation ) {
        case InputImageRotation.rotation90deg:
            return temp / divisor;

        case InputImageRotation.rotation270deg:
            return canvasSize.width - temp / divisor;

        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
            temp /= imageSize.width;
            return cameraLensDirection == CameraLensDirection.back ? temp : canvasSize.width - temp;
    }
}

double translateY(
    double y,
    Size canvasSize,
    Size imageSize,
    InputImageRotation rotation,
    CameraLensDirection cameraLensDirection
 ) {
    final divisor = Platform.isIOS ? imageSize.height : imageSize.width;

    switch( rotation ) {
        case InputImageRotation.rotation90deg:
        case InputImageRotation.rotation270deg:
            return y * canvasSize.height / divisor;
            
        case InputImageRotation.rotation0deg:
        case InputImageRotation.rotation180deg:
            return y * canvasSize.height / imageSize.height;
    }
 }