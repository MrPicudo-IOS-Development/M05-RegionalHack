/* ImagePredictor.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */

import Foundation
import UIKit
import CoreML
import Vision

class ImagePredictor {
    static let imageClassifier = createImageClassifier()

    struct Prediction {
        let classification: String
        let confidencePercentage: String
    }

    static func createImageClassifier() -> VNCoreMLModel {
        let defaultConfig = MLModelConfiguration()
        guard let imageClassifierWrapper = try? MobileNetV2(configuration: defaultConfig) else {
            fatalError("App failed to create an image classifier model instance.")
        }
        let imageClassifierModel = imageClassifierWrapper.model
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return imageClassifierVisionModel
    }

    func makePredictions(for photo: CIImage, orientation: CGImagePropertyOrientation, completionHandler: @escaping ([Prediction]?) -> Void) {
        let visionRequestHandler = { (request: VNRequest, error: Error?) in
            if let error = error {
                print("Error al realizar la clasificación: \(error)")
                completionHandler(nil)
                return
            }
            guard let observations = request.results as? [VNClassificationObservation] else {
                print("VNRequest produced the wrong result type: \(type(of: request.results)).")
                completionHandler(nil)
                return
            }
            let predictions = observations.map { observation in
                Prediction(classification: observation.identifier, confidencePercentage: observation.confidencePercentageString)
            }
            completionHandler(predictions)
        }

        let imageClassificationRequest = VNCoreMLRequest(model: ImagePredictor.imageClassifier, completionHandler: visionRequestHandler)
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(ciImage: photo, orientation: orientation)

        do {
            try handler.perform([imageClassificationRequest])
        } catch {
            print("Error al realizar la solicitud de clasificación: \(error)")
            completionHandler(nil)
        }
    }
}

extension VNClassificationObservation {
    var confidencePercentageString: String {
        return String(format: "%.2f%%", confidence * 100)
    }
}
