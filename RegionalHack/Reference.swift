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







*/

