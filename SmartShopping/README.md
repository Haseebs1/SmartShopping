#Smart Shopping – iOS Application
Smart Shopping is an iOS application designed to simplify and organize the shopping experience whether managing groceries, household items, office supplies, or planning for events, the app will help stay on budget and track  progress efficiently.

#Project Structure:

##Models (Models/)
-- ShoppingList.swift: Main shopping list model containing items
-- ShoppingItem.swift: Individual shopping item model
-- ShoppingTemplate.swift: Template structure for reusable shopping lists
TemplateItem.swift: Model for items inside templates

##ViewModels (ViewModels/)
-- AuthViewModel.swift: Handles user authentication and session
-- ListsViewModel.swift: Manages shopping lists with caching and sync 
-- TemplatesViewModel.swift: Manages template creation and reuse

##Views (Views/)

##Main (Views/Main/)

-- HomeView.swift: Dashboard with statistics and quick actions (Home Tab)
-- AnalyticsView.swift: Spending insights, charts, and reports (analytic Tab)
-- ContentView.swift: This helps show every tab


##Lists (Views/Lists)
-- ListsView.swift: Displays all shopping lists (List Tab)
-- ListDetailView.swift: View and edit individual lists
-- AddItemView.swift: Add more items list if shopping list already created
-- EditItemSheet.swift: Shows in sheet while adding a new list item.

##Templates (Views/Templates)
-- TemplatesView.swift: Browse and select templates (templates Tab)
-- AddTemplateItem.swift: Create custom template
-- UseTemplateView.swift: Lets you see template in more detail and use.



##Components (Views/Components/)
-- ProfileView.swift: See about user info and setting and about app (Profile tab)
-- Extensions.swift: custom extensions for Color, View, Date, and String to add reusable styling, formatting
-- LoadingView.swift: displaying loading states and error messages with retry functionality

##Create (Views/Create/)
-- CreateListView.swift: Create new shopping lists
-- CreateTemplateView.swift: Build and save templates

#Database
SupabaseManager.swift: Cloud backend and authentication management
Config.swift: Contains my project url and secret api key.

##Key Features
- 1.Shopping List Management
        Create, edit, and delete shopping lists
        Add and manage items with price, quantity, and notes
        Track purchased vs. pending items
        Real-time UI updates through ViewModels

- 2.Template System
        Prebuilt templates for common shopping needs
        Save existing lists as custom templates
        Create new lists instantly from templates
        
- 3. Data Persistence
        Offline caching with UserDefaults
        Automatic synchronization with Supabase when online
        Data preserved between app launches
        
- 4. Dashboard & Analytics
        Dashboard displays list counts, items, totals, and saved templates
        Analytics provides spending trends, category distribution, and monthly costs
        Built using Swift Charts for a clean, modern look
        
#Other files:
-- SplashScreenView: Show a quick splash screen when app launches with cart icon.
-- SmartShoppingApp: Main app file that helps with backend.

## Managers (Managers/ DataManager/)
-- DataManager.swift: coordinates real-time data change notifications between different parts of the app
                      (For some reason, list are not being update on home or list so, it helps somewhat but no fully.)
                      
#Package dependencies (Custom package)
##If file cannot find the custom import...
-- Supabase: https://github.com/supabase/supabase-swift (I did use this for database)
-- Keychain: https://github.com/evgenyneu/keychain-swift (While researching, it was suggested to use this for database security)
-- SDWebImageSwiftUI: https://github.com/SDWebImage/SDWebImageSwiftUI (I was gonna use this for image framework handling but didn't have enough time for new feature)
