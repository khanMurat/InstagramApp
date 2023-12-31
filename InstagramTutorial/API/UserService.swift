//
//  UserService.swift
//  InstagramTutorial
//
//  Created by Murat on 5.06.2023.
//

import FirebaseFirestore
import FirebaseAuth

typealias FireStoreCompletion = (Error?) -> Void

struct UserService {
    
    static func fetchUser(completion: @escaping (User)->Void ) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            
            let dictionary = snapshot?.data()
            
            let user = User(dictionary: dictionary!)
            
            completion(user)
        }
    }
    
    static func fetchUser(withUid uid:String,completion: @escaping (User)->Void ) {
       
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            
            let dictionary = snapshot?.data()
            
            let user = User(dictionary: dictionary!)
            
            completion(user)
        }
    }
    
    static func fetchUsers(completion : @escaping ([User])-> Void) {
        
        COLLECTION_USERS.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else{return}
            
//            guard let dictionaries = snapshot?.documents else {return}
//
//            var users : [User] = []
//
//            for dictionary in dictionaries {
//
//                var user = User(dictionary: dictionary.data())
//                users.append(user)
//            }
            
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            
            completion(users)
        }
        
    }
    
    static func fetchUsers(uid:String,completion : @escaping ([User])-> Void) {
        
        COLLECTION_USERS.getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else{return}
            
//            guard let dictionaries = snapshot?.documents else {return}
//
//            var users : [User] = []
//
//            for dictionary in dictionaries {
//
//                var user = User(dictionary: dictionary.data())
//                users.append(user)
//            }
            
            let users = snapshot.documents.map({User(dictionary: $0.data())})
            
            completion(users)
        }
        
    }
    
    static func follow(uid:String,completion : @escaping (FireStoreCompletion)){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:],completion: completion)
        }
    }
    
    static func unfollow(uid:String,completion : @escaping (FireStoreCompletion)){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following")
            .document(uid)
            .delete { error in
            
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers")
                .document(currentUid)
                .delete(completion: completion)
        }
    }
    
    static func checkIfUserFollowed(uid:String,completion : @escaping(Bool)->Void){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            completion(snapshot.exists)
            
        }
    }
    
    static func getUserStats(uid:String,completion : @escaping (UserStats)->Void) {
        
        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            var following = snapshot.count
            
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, error in
                
                guard let snapshot = snapshot else {return}
                
                var followers = snapshot.count
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, error in
                    
                    guard let documents = snapshot?.documents else {return}
                    
                    var posts = documents.count
                    
                    completion(UserStats(followers: followers, following: following, posts: posts))
                }
            }
            
        }
        
    }
    
}
