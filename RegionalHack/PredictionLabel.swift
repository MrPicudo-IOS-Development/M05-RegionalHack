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
