//
//  ShoppingBasketViewModel.swift
//  PayView
//
//  Created by 노민철 on 1/21/25.
//

import Foundation
import RealmSwift

class ShoppingBasketViewModel: ObservableObject {
    private var realm: Realm
    @Published var products: Results<RealMProduct>
    @Published var productCounts: Int = 0
    
    init() {
        // Realm 인스턴스 초기화
        realm = try! Realm()
        products = realm.objects(RealMProduct.self)
        productCountsUpdate()
    }
    
    func fetchProduct() {
        products = realm.objects(RealMProduct.self)
        productCountsUpdate()
    }
    
    // 상품 추가 함수
    func addProduct(product: Product, quantity: Int) {
//        let newProduct = RealMProduct()
//        newProduct.id = product.id
//        newProduct.name = product.name
//        newProduct.price = product.price
//        newProduct.imagePath = product.imagePath
//        newProduct.quantity = quantity
//        newProduct.category = product.category_id
//        
//        try! realm.write {
//            realm.add(newProduct)
//        }
        
        if let existingProduct = realm.objects(RealMProduct.self).filter("id == %@", product.id).first {
            // ✅ 이미 존재하는 경우: quantity만 증가
            try! realm.write {
                existingProduct.quantity += quantity
            }
        } else {
            // ✅ 존재하지 않는 경우: 새로 추가
            let newProduct = RealMProduct()
            newProduct.id = product.id
            newProduct.name = product.name
            newProduct.price = product.price
            newProduct.imagePath = product.imagePath
            newProduct.quantity = quantity
            newProduct.category = product.category_id

            try! realm.write {
                realm.add(newProduct)
            }
        }
    }
    
    // 상품 갯수 업데이트
    func updateProductQuantity(_ product: RealMProduct, quantity: Int) {
        try! realm.write {
            product.quantity += quantity
        }
        fetchProduct()
    }
    
    // 상품 삭제 함수
    func deleteProduct(_ product: RealMProduct) {
        try! realm.write {
            realm.delete(product)
        }
        fetchProduct()
    }
    
    // 상품 전체 삭제
//    func deleteAll() {
//        try! realm.write {
//            realm.deleteAll()
//        }
//    }
    func deleteAllProducts() {
        try! realm.write {
            let allProducts = realm.objects(RealMProduct.self)
            realm.delete(allProducts) // RealMProduct 테이블 데이터만 삭제
        }
    }

    
    // 상품 종류 수 업데이트
    func productCountsUpdate(){
        productCounts = products.count
    }
    
    // 전체 금액 계산
    func totalPrice() -> Double {
        return products.reduce(0) { result, product in
            result + Double(product.price) * Double(product.quantity)
        }
    }
}
