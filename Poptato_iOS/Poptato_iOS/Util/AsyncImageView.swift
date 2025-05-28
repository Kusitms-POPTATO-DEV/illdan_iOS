//
//  AsyncImageView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

import SwiftUI
import PDFKit

struct AsyncImageView: View {
    let imageURL: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: width, height: height)
            .clipShape(Circle())
        }
    }
}

struct PDFImageView: View {
    let imageURL: String
    var width: CGFloat
    var height: CGFloat
    @State private var pdfImage: UIImage? = nil
    @State private var isLoading = true

    var body: some View {
        Group {
            if let pdfImage = pdfImage {
                Image(uiImage: pdfImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: width, height: height)
            } else {
                Text("PDF 로드 실패")
                    .frame(width: width, height: height)
            }
        }
        .onAppear {
            loadPDF(from: imageURL)
        }
        .onChange(of: imageURL) { newValue in
            isLoading = true
            pdfImage = nil
            loadPDF(from: newValue)
        }
    }

    private func loadPDF(from urlString: String) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let document = PDFDocument(data: data) else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }

            if let pdfPage = document.page(at: 0) {
                let pdfImage = pdfPageToUIImage(pdfPage: pdfPage, size: CGSize(width: width, height: height))
                DispatchQueue.main.async {
                    self.pdfImage = pdfImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }.resume()
    }

    private func pdfPageToUIImage(pdfPage: PDFPage, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let context = ctx.cgContext
            let pdfBounds = pdfPage.bounds(for: .mediaBox)
            let scaleFactor = min(size.width / pdfBounds.width, size.height / pdfBounds.height)
            let newWidth = pdfBounds.width * scaleFactor
            let newHeight = pdfBounds.height * scaleFactor
            let xOffset = (size.width - newWidth) / 2
            let yOffset = (size.height - newHeight) / 2
            
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.saveGState()
            context.translateBy(x: xOffset, y: yOffset)
            context.scaleBy(x: scaleFactor, y: scaleFactor)
            pdfPage.draw(with: .mediaBox, to: context)
            context.restoreGState()
        }
    }

}
