import Foundation

enum SpecialtyCatalog {
    /// Orden de referencia para las especialidades más habituales del MIR.
    /// Las preguntas cargadas pueden usar cualquier nombre; esta lista solo
    /// ordena las que coinciden y añade al final las que no estén aquí.
    static let order: [String] = [
        "Cardiología",
        "Aparato Digestivo",
        "Cirugía General y del Aparato Digestivo",
        "Neumología y Cirugía Torácica",
        "Endocrinología y Nutrición",
        "Nefrología",
        "Urología",
        "Neurología y Neurocirugía",
        "Psiquiatría",
        "Reumatología",
        "Hematología y Hemoterapia",
        "Oncología Médica",
        "Enfermedades Infecciosas",
        "Dermatología",
        "Oftalmología",
        "Otorrinolaringología",
        "Ginecología y Obstetricia",
        "Pediatría",
        "Traumatología y Cirugía Ortopédica",
        "Angiología y Cirugía Vascular",
        "Cirugía Plástica",
        "Geriatría",
        "Cuidados Paliativos",
        "Medicina Familiar y Comunitaria",
        "Medicina Preventiva y Salud Pública",
        "Medicina Legal y Bioética",
        "Genética",
        "Fisiología",
        "Bioquímica",
        "Farmacología",
        "Microbiología",
        "Toxicología",
        "Alergología",
        "Rehabilitación y Medicina Física"
    ]

    static func sorted(_ names: [String]) -> [String] {
        names.sorted { a, b in
            let ia = order.firstIndex(of: a) ?? Int.max
            let ib = order.firstIndex(of: b) ?? Int.max
            if ia != ib { return ia < ib }
            return a < b
        }
    }
}
