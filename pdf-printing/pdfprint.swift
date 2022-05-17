import SwiftUI
import PDFKit
import UIKit

// Some ways to interact with Printing Util. TODO tiling.

struct pdf: View {
    @State private var showPicker = false
    @State private var printShowing = false
    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                HStack {
                    Text("Printing Methods")
                }
                HStack {
                    Spacer()
                    Button(action: {
                        self.showPicker.toggle()
                    }, label: {
                        Text("Select Printer")
                    })
                    .background(PrinterPickerController(showPrinterPicker: $showPicker))
                    Spacer()
                    Button(action: {
                        self.printShowing = true
                    }, label: {
                        Text("Print Settings")
                    })
                    .background(Group {
                        if self.printShowing {
                            PrintView() {
                                self.printShowing = false
                            }
                        }
                    })
                    Spacer()
                }
                PreView().frame(width: 350, height: 500)
            }
        }
    }
}

struct PrintView: UIViewControllerRepresentable
{
    let callback: () -> ()

    func makeUIViewController(context: Context) -> UIViewController
    {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Job Name"
        printInfo.outputType = .general
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
//        printController.printFormatter = formatter
        let pdfMetaData = [kCGPDFContextCreator: "Context Creator",
        kCGPDFContextAuthor: "Context Author"]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x:0, y:0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds:pageRect , format: format)
        let data = renderer.pdfData{ context in
            context.beginPage()
            let text = "Printing Below"
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)]
            text.draw(in : CGRect(x: 10, y: 10, width: 100, height: 100), withAttributes: attributes)
            if let image = UIImage(systemName: "photo"){
                image.draw(in: CGRect(x: 150, y : 150,
                       width: 100 , height: 100) )
            }
            if let image = UIImage(systemName: "photo"){
                image.draw(in: CGRect(x: 200, y : 200,
                       width: 150 , height: 150) )
            }
        }
        printController.printingItem = data
        let controller = UIViewController()
        DispatchQueue.main.async {
            printController.present(animated: true, completionHandler: { _, _, _ in
                printController.printFormatter = nil
                self.callback()
            })
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context)
    {
    }
}

struct PreView: UIViewRepresentable {

    func makeUIView(context: Context) -> PDFView {
        let pdfMetaData = [kCGPDFContextCreator: "Context Creator",
        kCGPDFContextAuthor: "Context Author"]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let pageRect = CGRect(x:0, y:0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds:pageRect , format: format)
        let data = renderer.pdfData{ context in
            context.beginPage()
            let text = "Printing Pages"
            let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10)]
            text.draw(in : CGRect(x: 10, y: 10, width: 100, height: 100), withAttributes: attributes)

            if let image = UIImage(systemName: "photo"){
                image.draw(in: CGRect(x: 150, y : 150,
                       width: 50, height: 40) )
            }

        }
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        return
    }
}

struct PrinterPickerController: UIViewControllerRepresentable {
    @Binding var showPrinterPicker: Bool
    fileprivate let controller = UIViewController()
    
    func makeUIViewController(context: Context) -> UIViewController {
        controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showPrinterPicker && context.coordinator.activePicker == nil {
            let picker = UIPrinterPickerController(initiallySelectedPrinter: nil)
            context.coordinator.activePicker = picker

            picker.delegate = context.coordinator
            picker.present(animated: true) { (picker, flag, error) in
                if let printer =  picker.selectedPrinter {
                    dump(printer)
                }

                context.coordinator.activePicker = nil
                self.showPrinterPicker = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPrinterPickerControllerDelegate {
        let owner: PrinterPickerController
        var activePicker: UIPrinterPickerController?

        init(_ owner: PrinterPickerController) {
            self.owner = owner
        }

        func printerPickerControllerParentViewController(_ printerPickerController: UIPrinterPickerController) -> UIViewController? {
            self.owner.controller
        }
    }

    typealias UIViewControllerType = UIViewController
}

struct pdf_Previews: PreviewProvider {
    static var previews: some View {
        pdf()
    }
}
