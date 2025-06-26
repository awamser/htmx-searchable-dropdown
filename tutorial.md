# Building a Searchable Dropdown with Swift Vapor, HTMX, and AlpineJS

This tutorial will guide you through creating a modern, interactive searchable dropdown component using Swift Vapor for the backend, HTMX for dynamic content loading, and AlpineJS for client-side interactivity.

## Technology Stack

- **Swift Vapor** - Backend web framework
- **HTMX** - Dynamic content loading without full page refreshes
- **AlpineJS** - Client-side state management and interactions
- **Leaf Templates** - Server-side templating engine
- **Tailwind CSS** - Utility-first CSS framework for styling

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Data Model](#data-model)
4. [Backend Controller](#backend-controller)
5. [Leaf Templates](#leaf-templates)
6. [Frontend Implementation](#frontend-implementation)
7. [Testing](#testing)
8. [Customization Options](#customization-options)

## Prerequisites

- Swift 5.9+ installed
- Vapor CLI installed (`brew install vapor/tap/vapor`)
- Basic knowledge of Swift and web development

## Project Setup

### Step 1: Create a new Vapor project

```bash
vapor new htmx-searchable-dropdown
cd htmx-searchable-dropdown
```

### Step 2: Configure Package.swift

Ensure your `Package.swift` includes the necessary dependencies:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HtmxSearchableDropdown",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "HtmxSearchableDropdown",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "HtmxSearchableDropdownTests",
            dependencies: ["HtmxSearchableDropdown"]
        )
    ]
)
```

## Data Model

First, let's create a simple User model to represent our data:

**File:** `Sources/HtmxSearchableDropdown/Models/User.swift`

```swift
import Vapor

struct User: Content {
    let id: Int
    let name: String
    let email: String
}
```

> **Note:** In a real application, you would typically use Fluent ORM with a database. This example uses in-memory data for simplicity.

## Backend Controller

Create a controller to handle the search functionality:

**File:** `Sources/HtmxSearchableDropdown/Controllers/SearchController.swift`

```swift
import Leaf
import Vapor

struct SearchContext: Encodable {
    let users: [User]
    let searchTerm: String
    let tooShort: Bool
}

struct SearchController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("", use: index)
        routes.get("search", use: search)
    }

    func index(req: Request) async throws -> View {
        return try await req.view.render("index")
    }

    func search(req: Request) async throws -> View {
        // Get search query
        let searchTerm = try req.query.get(String.self, at: "q")

        // Check if search term is less than 3 characters
        if searchTerm.count < 3 {
            let context = SearchContext(users: [], searchTerm: searchTerm, tooShort: true)
            return try await req.view.render("partials/dropdown-results", context)
        }

        // Sample data - in real app, this would come from database
        let allUsers = [
            User(id: 1, name: "Isaac Newton", email: "newton@math.com"),
            User(id: 2, name: "Leonhard Euler", email: "euler@math.com"),
            User(id: 3, name: "Carl Friedrich Gauss", email: "gauss@math.com"),
            User(id: 4, name: "Alan Turing", email: "turing@math.com"),
            User(id: 5, name: "Emmy Noether", email: "noether@math.com"),
            User(id: 6, name: "Pythagoras", email: "pythagoras@math.com"),
            User(id: 7, name: "Euclid", email: "euclid@math.com"),
            User(id: 8, name: "Archimedes", email: "archimedes@math.com"),
            User(id: 9, name: "Bernhard Riemann", email: "riemann@math.com"),
            User(id: 10, name: "Pierre de Fermat", email: "fermat@math.com"),
            User(id: 11, name: "Sophie Germain", email: "germain@math.com"),
            User(id: 12, name: "Ada Lovelace", email: "lovelace@math.com"),
            User(id: 13, name: "David Hilbert", email: "hilbert@math.com"),
            User(id: 14, name: "Henri Poincaré", email: "poincare@math.com"),
            User(id: 15, name: "John von Neumann", email: "neumann@math.com"),
        ]

        // Filter users based on search term
        let filteredUsers =
            searchTerm.isEmpty
            ? allUsers
            : allUsers.filter { user in
                user.name.lowercased().contains(searchTerm.lowercased())
                    || user.email.lowercased().contains(searchTerm.lowercased())
            }

        // Return partial view with filtered results
        let context = SearchContext(users: filteredUsers, searchTerm: searchTerm, tooShort: false)
        return try await req.view.render("partials/dropdown-results", context)
    }
}
```

## Leaf Templates

### Main Template

Create the main page template:

**File:** `Resources/Views/index.leaf`

```html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HTMX Searchable Dropdown with Vapor</title>
  <script src="https://unpkg.com/htmx.org@2.0.0"></script>
  <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="min-h-screen bg-gray-100 py-12">
  <div class="mx-auto max-w-2xl px-4">
    <h1 class="mb-8 text-3xl font-bold text-gray-800">Searchable Dropdown Example</h1>

    <div class="rounded-lg bg-white p-6 shadow-md">
      <label class="mb-2 block text-sm font-medium text-gray-700">
        Select a User
      </label>

      <!-- Searchable Dropdown Container -->
      <div class="relative" x-data="{ open: false, selected: null }">
        <!-- Selected Value Display -->
        <button type="button" @click="open = !open" @click.away="open = false"
          class="w-full rounded-md border border-gray-300 bg-white px-4 py-2 text-left shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500">
          <span x-show="!selected" class="text-gray-400">Select a user...</span>
          <span x-show="selected" x-text="selected"></span>
          <svg class="absolute right-3 top-3 h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
          </svg>
        </button>

        <!-- Dropdown Panel -->
        <div x-show="open" x-transition:enter="transition ease-out duration-100"
          x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100"
          x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100"
          x-transition:leave-end="transform opacity-0 scale-95"
          class="absolute z-10 mt-1 w-full rounded-md border border-gray-300 bg-white shadow-lg" style="display: none;">
          <!-- Search Input -->
          <div class="border-b border-gray-200 p-2">
            <input type="text"
              class="w-full rounded-md border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Search users (min. 3 characters)..." hx-get="/search" hx-trigger="keyup changed delay:300ms"
              hx-target="#dropdown-results" hx-indicator="#loading-spinner" hx-sync="this:replace"
              hx-on::htmx:config-request="if(event.detail.parameters.q.length < 3) { event.preventDefault(); document.getElementById('dropdown-results').innerHTML = '<div class=\'px-4 py-2 text-sm text-gray-500\'>Type at least 3 characters to search...</div>'; }"
              name="q" @click.stop>
            <!-- Loading Spinner -->
            <div id="loading-spinner" class="htmx-indicator absolute right-4 top-4">
              <svg class="h-5 w-5 animate-spin text-gray-400" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
                </path>
              </svg>
            </div>
          </div>

          <!-- Results Container -->
          <div id="dropdown-results" class="max-h-60 overflow-y-auto">
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Alpine.js for dropdown state management -->
  <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script>
</body>

</html>
```

### Results Partial Template

Create the partial template for search results:

**File:** `Resources/Views/partials/dropdown-results.leaf`

```html
<!-- If no search term, show initial message -->
#if(searchTerm == nil || searchTerm == ""):
<div class="py-2 text-sm text-gray-500 px-4">
    Type at least 3 characters to search...
</div>
#elseif(tooShort == true):
<div class="py-2 text-sm text-gray-500 px-4">
    Type at least 3 characters to search...
</div>
#else:
#if(count(users) == 0):
<div class="py-3 text-sm text-gray-500 px-4">
    No users found matching "#(searchTerm)"
</div>
#else:
#for(user in users):
<button type="button"
    class="w-full text-left px-4 py-2 hover:bg-gray-100 focus:bg-gray-100 focus:outline-none transition-colors duration-150"
    @click="selected = '#(user.name) (#(user.email))'; open = false">
    <div class="flex items-center justify-between">
        <div>
            <p class="text-sm font-medium text-gray-900">#(user.name)</p>
            <p class="text-sm text-gray-500">#(user.email)</p>
        </div>
        <span class="text-gray-400">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
        </span>
    </div>
</button>
#endfor
#endif
#endif
```

## Frontend Implementation Details

### Key Technologies Used

| Technology | Purpose | Version |
|------------|---------|---------|
| HTMX | Dynamic content loading without full page refreshes | 2.0.0 |
| AlpineJS | Client-side state management and interactions | 3.x.x |
| Tailwind CSS | Utility-first CSS framework for styling | Latest CDN |

### HTMX Attributes Explained

- **`hx-get="/search"`** - Makes GET request to /search endpoint
- **`hx-trigger="keyup changed delay:300ms"`** - Triggers on keyup with 300ms debounce
- **`hx-target="#dropdown-results"`** - Updates the results container
- **`hx-indicator="#loading-spinner"`** - Shows loading spinner during request
- **`hx-sync="this:replace"`** - Cancels previous requests when new one starts

### AlpineJS Features Used

- **`x-data`** - Defines reactive data properties
- **`@click`** - Event handlers
- **`@click.away`** - Closes dropdown when clicking outside
- **`x-show`** - Conditional visibility
- **`x-text`** - Text content binding
- **`x-transition`** - Smooth animations

## Testing

### Step 1: Run the application

```bash
swift run
```

### Step 2: Open your browser

Navigate to `http://localhost:8080`

### Step 3: Test the functionality

- Click the dropdown to open it
- Type at least 3 characters to trigger search
- Observe the loading spinner
- Select a user to close the dropdown
- Try typing less than 3 characters to see validation

## Customization Options

### 1. Change Minimum Search Length

Modify the validation in both the controller and frontend:

```swift
// In SearchController.swift
if searchTerm.count < 2 { // Change from 3 to 2
    let context = SearchContext(users: [], searchTerm: searchTerm, tooShort: true)
    return try await req.view.render("partials/dropdown-results", context)
}
```

### 2. Add Custom Styling

You can customize the appearance by modifying the Tailwind classes or adding custom CSS:

```html
<style>
.custom-dropdown {
    @apply bg-blue-50 border-blue-200;
}
.custom-dropdown:focus {
    @apply border-blue-500 ring-blue-500;
}
</style>
```

### 3. Add Keyboard Navigation

Enhance accessibility with keyboard support:

```html
<div x-data="{ 
    open: false, 
    selected: null, 
    highlightedIndex: -1,
    results: []
}" 
@keydown.arrow-down.prevent="highlightedIndex = Math.min(highlightedIndex + 1, results.length - 1)"
@keydown.arrow-up.prevent="highlightedIndex = Math.max(highlightedIndex - 1, -1)"
@keydown.enter.prevent="if(highlightedIndex >= 0) selectResult(results[highlightedIndex])">
```

### 4. Add Loading States

Customize the loading indicator:

```html
<div id="loading-spinner" class="htmx-indicator">
    <div class="flex items-center justify-center p-4">
        <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
        <span class="ml-2 text-sm text-gray-600">Searching...</span>
    </div>
</div>
```

## 🎉 Congratulations!

You've successfully implemented a modern, interactive searchable dropdown using Swift Vapor, HTMX, and AlpineJS. This implementation provides:

- Real-time search with debouncing
- Smooth animations and transitions
- Loading states and error handling
- Responsive design with Tailwind CSS
- Accessible keyboard navigation
- Server-side validation

## Next Steps

- Integrate with a real database using Fluent ORM
- Add pagination for large datasets
- Implement caching for better performance
- Add more advanced filtering options
- Create reusable components for other parts of your application

## Important Notes

> **Warning:** This example uses in-memory data. In production, use a proper database.
> 
> - Consider implementing rate limiting for the search endpoint
> - Add proper error handling for network failures
> - Test thoroughly across different browsers and devices 