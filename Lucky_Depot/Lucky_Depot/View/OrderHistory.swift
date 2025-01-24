//
//  OrderHistory.swift
//  final_project
//
//  Created by Eunji Kim on 1/21/25.
//

import SwiftUI

struct OrderHistory: View {
    @Binding var navigationPath: NavigationPath

    var body: some View {
            ZStack {
                backgroundColor
                  .ignoresSafeArea()
                VStack(alignment: .leading, content: {
                
                 Text("Recent Orders")
                        .font(.system(size:20))
                        .padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing:10, content: {
                        HStack(content: {
                            VStack (alignment: .leading, spacing: 5){
                                Text("2025-1-20")
                                
                                HStack(content: {
                                    Text("Order No: ")
                                    Text("123456")
                                })
                                .foregroundStyle(.gray)
                            }
                           
                            Spacer()

                        })
                        
                        Divider()
                        HStack( spacing: 20,content: {
                            Image("pen")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .clipShape(.rect(cornerRadius: 10))
                            VStack (alignment: .leading, content: {
                                Text("Ballpoint Pen")
                                Text("Quantity:"+" "+"1")
                                    .foregroundStyle(.gray)
                            
                            })
                            Spacer()
                            Text("1 other")
                                .foregroundStyle(.gray)
                        })
                        
                        
                        Divider()
                        HStack {
                            Text("Total Price")

                            Spacer()
                            Text("$27.5")
                                .foregroundStyle(.price)
                                .bold()
                        }
                        .font(.system(size: 18))
                        .padding(.vertical, 5)
                        
                        VStack(alignment: .center, content: {
                            Button("View Order Details", action: {
                                navigationPath.append("OrderDetailsView")

                            })
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundStyle(.button2)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.gray.opacity(0.4), lineWidth: 1)
                                }

                        })
                        VStack(alignment: .center, content: {
                            Button("View Shipping Status", action: {
                                navigationPath.append("ShippingStatusView")
                            })
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundStyle(.white)
                                .background(.button2)
                                .cornerRadius(10)

                        })

                        
                    })
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 10))
                    
                   
                    
                 Text("Past Orders")
                        .font(.system(size:20))
                        .padding(.vertical, 10)
                    
                    Spacer()
                    
                })
                .padding()
                .navigationTitle("Order History")
                .navigationBarTitleDisplayMode(.inline)
                
            }
            
      
      
      
        
        
    }
}


//#Preview {
//    OrderHistory(navigationPath: <#Binding<NavigationPath>#>)
//}
