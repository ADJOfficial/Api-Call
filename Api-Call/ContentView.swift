//
//  ContentView.swift
//  Api-Call
//
//  Created by ADJ on 15/12/2023.
//

import SwiftUI

struct Cars: Hashable , Codable {
    
    var id: Int = 0
    var name: String
    var model: String
    var technology: String
    
}

class ViewModel: ObservableObject {
    
    @Published var crs: [Cars] = []
    
    func fetchApiData() {
        guard let url = URL(string: "http://localhost:7862/cars")
                
        else{
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            
            guard let data = data , error == nil
                    
            else {
                return
            }
            
            // Convert to JSON
            
            do{
                let cars = try JSONDecoder().decode([Cars].self, from: data)
                DispatchQueue.main.async {
                    self?.crs = cars
                }
            }
            catch{
                print("Error While Getting Data")
            }
        }
        task.resume()
    }
}


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State private var isFetchingData = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Audi Point")
                    .font(.largeTitle)
                    .foregroundColor(Color.gray)
                    .bold()
                
                Spacer()
                
                HStack{
                    
                    Spacer()
                    
                    Button("Fetch Data"){
                        isFetchingData = true
                        viewModel.fetchApiData()
                    }
                    .disabled(isFetchingData)
                    .padding()
                    .font(.title)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(30)
                    
                    Spacer()
                    
                    NavigationLink(destination: Save()){
                        Text("Insert Data")
                            .padding()
                            .font(.title)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(30)
                    }
                
                    Spacer()
                }
                
                NavigationLink(destination: Login()){
                    Text("Logout")
                        .padding()
                        
                }
                
                if isFetchingData {
                    List {
                        ForEach(viewModel.crs, id: \.self) { cr in
                            VStack {
                                Text("\(cr.id)")
                                Text(cr.name)
                                Text(cr.model)
                                Text(cr.technology)
                            }
                            .padding(10)
                        }
                    }
                    .navigationTitle("Audi")
                }
            }
            .onAppear {
                if isFetchingData {
                    viewModel.fetchApiData()
                }
            }
            .background(Color.yellow)
        }
    }
}
    

//View For Saving Screen
struct Save: View {
    @State private var id: Int = 0
    @State private var name = ""
    @State private var model = ""
    @State private var technology = ""
    var body: some View{
        VStack{
            Text("Hurry Up! Send Data")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.gray)
            
            Spacer()
            TextField("Enter ID", value: $id ,formatter: NumberFormatter())
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(8)
                .foregroundColor(.black) // Set text color
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter Name", text: $name)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(8)
                .foregroundColor(.black) // Set text color
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter Model", text: $model)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(8)
                .foregroundColor(.black) // Set text color
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter Technology", text: $technology)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(8)
                .foregroundColor(.black) // Set text color
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
              
            Spacer()
            
            Button("Save"){
                save()
            }
            .padding()
            .font(.title)
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(20)            
        }
        .background(Color.yellow)
    }
    func save() {
        guard let url = URL(string: "http://localhost:7862/postCars") else {
            return
        }
        
        let car = [
            "id": id,
            "name": name,
            "model": model,
            "technology": technology
        ] as [String : Any]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: car) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONSerialization.jsonObject(with: data)
                    print("Result from server:", result)
                } catch {
                    print("Error parsing JSON:", error)
                }
            } else if let error = error {
                print("Error making request:", error)
            }
        }.resume()
    }
}


struct Login: View {

    @State private var userName = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
    @State private var loginErrorMessage = ""

    var body: some View {
        VStack{
            Text("! MongoDB System !")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            TextField("Enter Username", text: $userName)
                .padding(10)
                .textFieldStyle(.roundedBorder)
                .border(.cyan)
                .cornerRadius(20)
        
            SecureField("Enter Password" ,text: $password)
                .padding(10)
                .textFieldStyle(.roundedBorder)
                
                .border(.cyan)
                .cornerRadius(20)
            
            if !loginErrorMessage.isEmpty {
                            Text(loginErrorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
            Spacer()
            
            Button("Login"){
                login()
            }
            .padding()
            .font(.title)
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(20)
        }
        .background(Color.yellow) // Set the background color here
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
    func login() {
        if userName.uppercased() == "ADJ" && password.lowercased() == "abc123"{
            Text("Succeddfully Login")
            isLoggedIn = true
        }
        else{
            loginErrorMessage = "Invalid Username / Password"
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
//struct ContentView: View {
//
//    @StateObject var viewModel = ViewModel()
//    @State private var isFetchingData = false
//
//    var body: some View {
//        NavigationView{
//            List {
//                ForEach(viewModel.crs , id:\ .self) { cr in
//                    VStack{
//                        Text("\(cr.id)")
//                        Text(cr.name)
//                        Text(cr.model)
//                        Text(cr.technology)
//                    }
//                    .padding(3)
//                }
//            }
//            .navigationTitle("Names")
//            .onAppear {
//                viewModel.fetchApiData()
//            }
//        }
//    }
//}


