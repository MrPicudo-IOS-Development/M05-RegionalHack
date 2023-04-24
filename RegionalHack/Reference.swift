/* *** *** *** REFERENCE *** *** *** */
/* C+A
 
 /* PredictionApp.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */
 
 import SwiftUI
 import CoreML
 import Vision
 import UIKit
 
 /// Vista principal de la aplicación, es la primera que se carga al iniciar la app.
 struct PredictionApp: View {
 
 /// Variables de estado para mostrar la imagen y el texto de predicción del modelo de ML. También se define el tipo de entrada del UIImagePickerController como "camara" inicialmente. Y el booleano que controla cuándo se muestra el imagePicker en la app, que cambia a "true" cuando se presiona alguno de los dos botones de la aplicación.
 @State private var image: UIImage?
 @State private var predictionText = "No Prediction"
 @State private var showingImagePicker = false
 @State private var inputSourceType: UIImagePickerController.SourceType = .camera
 
 var body: some View {
 // VStack de nuestra vista, contiene una imagen, una etiqueta, y dos botones que se muestran en la misma línea con un HStack.
 VStack {
 /// Una manera de "crear objetos" en una vista de SwiftUI es por medio de otras vistas, declaradas en archivos por separado. En las vistas ImageView y PredictionLabel, tenemos atributos que se definieron de tipo @Binding, por eso se utiliza un signo de dólar, para pasar la variable de estado enlazada a varias vistas.
 ImageView(image: $image) // Mostramos la imagen y pasamos la propiedad como un @Binding
 PredictionLabel(predictionText: $predictionText) // Mostramos la etiqueta y pasamos la propiedad como un @Binding
 // Dentro del VStack, tenemos un HStack para mostrar los dos botones que nos van a permitir interactuar con la app.
 HStack {
 // Botón para acceder a la cámara
 Button(action: {
 inputSourceType = .camera // Establecemos la fuente de entrada del inputSourceType que es de tipo UIImagePickerController, como la cámara.
 showingImagePicker = true // Mostramos la "sheet" que está relacionada con el VStack, la cual se activa si este booleano es "true"
 }) {
 Image(systemName: "camera") // Propiedades básicas del botón.
 .font(.largeTitle)
 .padding()
 }
 .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera)) // Se desactiva si la cámara NO está disponible.
 // Botón para acceder a la biblioteca de fotos
 Button(action: {
 inputSourceType = .photoLibrary
 // Agregamos esta línea de DispatchQueue para que no se active la cámara al presionar el botón de la librería.
 DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
 showingImagePicker = true
 }
 }) {
 Image(systemName: "photo")
 .font(.largeTitle)
 .padding()
 }
 }
 }
 .sheet(isPresented: $showingImagePicker) { // Presentamos ImagePicker como una hoja cuando showingImagePicker sea "true"
 // Creamos una instancia de ImagePicker con el tipo de fuente de la imagen, la imagen que se va a mostrar enlazada, y se manda a llamar a la función makePrediction una vez que la imagen sea seleccionada
 ImagePicker(sourceType: inputSourceType, selectedImage: $image, onImagePicked: { selectedImage in
 makePrediction(for: selectedImage)
 })
 }
 }
 
 /// Función para realizar predicciones usando CoreML y Vision en la imagen seleccionada
 func makePrediction(for userImage: UIImage) {
 // Primero que nada, convertimos la imagen seleccionada a una imagen de tipo CIImage
 guard let ciimage = CIImage(image: userImage) else {
 fatalError("Couldn't convert to CIImage :c")
 }
 // Obtenemos la orientación de la imagen de entrada, la versión que no está convertida a CIImage
 let orientation = CGImagePropertyOrientation(rawValue: UInt32(userImage.imageOrientation.rawValue))!
 // Creamos una instacia de la clase ImagePredictor (no es una estructura de tipo View)
 let imagePredictor = ImagePredictor()
 // Usamos el método .makePredictions del objeto imagePredictor con los parámetros de ciimage y orientation obtenidos.
 imagePredictor.makePredictions(for: ciimage, orientation: orientation) { predictions in
 // Si se obtienen predicciones del modelo, las ordenamos de mayor a menor, y nos quedamos con la primera (la que tiene más porcentaje de confianza)
 if let predictions = predictions {
 let topPrediction = predictions.sorted { $0.confidencePercentage > $1.confidencePercentage }.first
 // Nos aseguramos de que haya una topPrediction después de ejecutarse el código anterior.
 if let topPrediction = topPrediction {
 // Creamos el texto que se muestra en la predictionLabel, con la clasificación obtenida de la mejor predicción y el correspondiente valor de confianza.
 predictionText = "Classification: \(topPrediction.classification), Confidence: \(topPrediction.confidencePercentage)"
 }
 }
 }
 }
 }
 
 struct PredictionApp_Previews: PreviewProvider {
 static var previews: some View {
 PredictionApp()
 }
 }
 
 - - -
 
 
 
 /* ImageView.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */
 
 import SwiftUI
 
 struct ImageView: View {
 @Binding var image: UIImage?
 
 var body: some View {
 Group {
 if let image = image {
 Image(uiImage: image)
 .resizable()
 .scaledToFit()
 } else {
 Text("No Image")
 .font(.largeTitle)
 .foregroundColor(.gray)
 }
 }
 }
 }
 
 struct ImageView_Previews: PreviewProvider {
 static var previews: some View {
 ImageView(image: .constant(UIImage(systemName: "photo")))
 }
 }
 
 - - -
 
 
 
 /* PredictionLabel.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */
 
 import SwiftUI
 
 /// Vista secundaria: una etiqueta que muestra la predicción y el porcentaje de confianza obtenidas del modelo de ML.
 struct PredictionLabel: View {
 @Binding var predictionText: String
 var body: some View {
 Text(predictionText)
 .font(.headline)
 .padding()
 }
 }
 
 struct PredictionLabel_Previews: PreviewProvider {
 static var previews: some View {
 PredictionLabel(predictionText: .constant("Classification: Cat, Confidence: 95.32%"))
 }
 }
 
 - - -



/* ImagePicker.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = userImage
                parent.onImagePicked(userImage)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

- - -
 
 
 
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
 
 - - -
 
 

/* ContentView.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */

import SwiftUI

struct ContentView: View {
    var body: some View {
        PredictionApp()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

- - -



/* RegionalHackApp.swift --> RegionalHack. Created by Miguel Torres on 23/04/23. */

import SwiftUI

@main
struct RegionalHackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

*/

