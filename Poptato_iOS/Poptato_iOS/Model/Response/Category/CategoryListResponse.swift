//
//  CategoryListResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

struct CategoryListResponse: Codable {
    let categories: [CategoryModel]
    let totalPageCount: Int
}
