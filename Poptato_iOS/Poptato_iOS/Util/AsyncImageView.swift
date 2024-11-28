//
//  AsyncImageView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

import SwiftUI
import SVGKit

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

struct SVGImageView: View {
    let imageURL: String
    var width: CGFloat
    var height: CGFloat
    @State private var svgImage: SVGKImage? = nil
    @State private var isLoading = true

    var body: some View {
        Group {
            if let svgImage = svgImage {
                Image(uiImage: svgImage.uiImage)
                    .resizable()
                    .frame(width: width, height: height)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: width, height: height)
            } else {
                Text("SVG 로드 실패")
                    .frame(width: width, height: height)
            }
        }
        .onAppear {
            loadSVGImage(from: imageURL)
        }
        .onChange(of: imageURL) {
            isLoading = true
            svgImage = nil
            loadSVGImage(from: imageURL)
        }
    }

    private func loadSVGImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }
            
            if let svgImage = SVGKImage(data: data) {
                DispatchQueue.main.async {
                    self.svgImage = svgImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}
