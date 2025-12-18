//
//  TemplatesViewModel.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import Foundation
import Combine
import Supabase

@MainActor
class TemplatesViewModel: ObservableObject {
    @Published var templates: [ShoppingTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    func fetchTemplates() async {
        guard let userId = supabase.currentUserId else {
            errorMessage = "Not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let templates: [ShoppingTemplate] = try await supabase.database
                .from("shopping_templates")
                .select("*, template_items(*)")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.templates = templates
            isLoading = false
        } catch {
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createTemplate(name: String, description: String? = nil, category: String = "General", isPublic: Bool = false) async throws -> ShoppingTemplate {
        guard let userId = supabase.currentUserId else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        let newTemplate = ShoppingTemplate(
            userId: userId,
            name: name,
            description: description,
            category: category,
            isPublic: isPublic
        )
        
        let createdTemplate: ShoppingTemplate = try await supabase.database
            .from("shopping_templates")
            .insert(newTemplate)
            .select()
            .single()
            .execute()
            .value
        
        templates.insert(createdTemplate, at: 0)
        return createdTemplate
    }
    
    func deleteTemplate(_ template: ShoppingTemplate) async throws {
        try await supabase.database
            .from("shopping_templates")
            .delete()
            .eq("id", value: template.id)
            .execute()
        
        templates.removeAll { $0.id == template.id }
    }
    
    func toggleFavorite(_ template: ShoppingTemplate) async throws {
        let updated = try await supabase.database
            .from("shopping_templates")
            .update(["is_favorite": !template.isFavorite])
            .eq("id", value: template.id)
            .select()
            .single()
            .execute()
            .value as ShoppingTemplate

        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = updated
        }
    }

    func incrementTimesUsed(_ template: ShoppingTemplate) async throws {
        let updated = try await supabase.database
            .from("shopping_templates")
            .update(["times_used": template.timesUsed + 1])
            .eq("id", value: template.id)
            .select()
            .single()
            .execute()
            .value as ShoppingTemplate
        
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = updated
        }
    }
    

    func updateTemplate(_ updatedTemplate: ShoppingTemplate) {
        if let index = templates.firstIndex(where: { $0.id == updatedTemplate.id }) {
            templates[index] = updatedTemplate
        }
    }

    func refresh() async {
        await fetchTemplates()
    }
}
