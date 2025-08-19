# API Layer Architecture Reference

## Philosophy

This API layer was designed to isolate and manage the complexity of an ill-written backend API that requires multi-step workflows for simple operations. The architecture follows strict separation of concerns with three distinct layers:

1. **API Layer** (`lib/api/`): Raw HTTP calls and complex API workflows
2. **Services Layer** (`lib/services/`): Business logic and validation  
3. **UI Layer** (`lib/screens/`, `lib/widgets/`): State management and presentation

## Folder Structure

```
lib/api/
├── api_client.dart           # Singleton HTTP client with auth
├── api_exception.dart        # Custom exceptions hierarchy
├── endpoints/                # Direct 1:1 API mappings
│   ├── auth/                 # Authentication endpoints
│   ├── chats/               # Chat CRUD operations
│   └── completions/         # AI completion endpoints
└── wrappers/                # Complex multi-step workflows
    └── send_message/        # Orchestrates 6-step message workflow
```

## Core Concepts

### Endpoints vs Wrappers

**Endpoints** (`lib/api/endpoints/`):
- Map 1:1 to backend API routes
- Simple request/response patterns
- No business logic or complex orchestration
- Example: `POST /api/v1/auths/signin` → `AuthEndpoints.signIn()`

**Wrappers** (`lib/api/wrappers/`):
- Handle complex multi-step API workflows
- Orchestrate multiple endpoint calls
- Contain API-specific logic to work around backend limitations
- Example: `SendMessageApi.sendMessage()` performs 6 sequential API calls

### API Client Pattern

- `ApiClient` is a singleton configured once after authentication
- All endpoints use the same client for consistency
- Automatic header injection (auth, content-type)
- Centralized error handling and logging

## Key Principles

### ✅ DO

- **Keep endpoints pure**: One endpoint class per API domain (auth, chats, completions)
- **Co-locate types**: Each endpoint folder contains both types and implementation
- **Use wrappers for complexity**: Multi-step workflows belong in `wrappers/`
- **Throw specific exceptions**: Use `ApiException`, `AuthException`, `ValidationException`
- **Re-export models**: Don't duplicate existing domain models
- **Document complex workflows**: Explain the "why" behind multi-step processes

### ❌ DON'T

- **Don't put business logic in endpoints**: Keep them as thin HTTP wrappers
- **Don't bypass ApiClient**: Always use the singleton for consistency
- **Don't duplicate models**: Re-export from `lib/models/` instead
- **Don't mix concerns**: API layer handles HTTP, services handle business logic
- **Don't expose internal workflow steps**: Wrappers should have clean public interfaces

## Working with the Backend API

This backend API has several quirks that the architecture handles:

### Message Sending Workflow

The backend requires a 6-step process to send a single message:

1. **Prepare messages**: Generate UUIDs, create user/assistant message pair
2. **First update**: POST chat with placeholder assistant message
3. **Get completion**: POST to `/api/chat/completions` 
4. **Notify completion**: POST to `/api/chat/completed`
5. **Update assistant**: Replace placeholder with actual AI response
6. **Final update**: POST complete chat history with relationships

This complexity is isolated in `SendMessageApi` so the rest of the codebase can simply call:

```dart
final response = await SendMessageApi.sendMessage(request);
```

### Authentication Flow

The API client is configured after successful authentication:

```dart
final response = await AuthEndpoints.signIn(serverUrl, request);
ApiClient.instance.configure(serverUrl, response.token);
```

All subsequent API calls automatically include the auth token.

## Error Handling Strategy

```
NetworkException (connection issues)
├── ApiException (HTTP errors)
│   ├── AuthException (401, 403)
│   └── ValidationException (400, business logic)
```

Endpoints should catch and re-throw with appropriate exception types. Services layer handles user-facing error messages.

## Testing Strategy

The layered architecture enables focused testing:

- **Mock `ApiClient`**: Test endpoint error handling and request formatting
- **Mock endpoints**: Test wrapper orchestration logic
- **Mock wrappers**: Test service business logic
- **Mock services**: Test UI state management

## Extension Guidelines

### Adding New Endpoints

1. Create folder: `lib/api/endpoints/new_domain/`
2. Add types: `new_domain_types.dart` with request/response models
3. Add endpoints: `new_domain_endpoints.dart` with static methods
4. Create service: `lib/services/new_domain_service.dart` for business logic

### Adding Complex Workflows

If a new API operation requires multiple steps:

1. Create wrapper: `lib/api/wrappers/new_workflow/`
2. Define types: Internal workflow types and public interface
3. Implement workflow: Break down into private step methods
4. Add business service: Wrap the API workflow with validation

## Migration Notes

This architecture was created by extracting 200+ lines of mixed HTTP/business logic from `AuthService`. The old pattern of mixing concerns made testing difficult and created tight coupling between UI and API implementation details.

The new structure ensures that:
- UI components don't know about HTTP details
- API complexities don't leak into business logic
- Each layer can be tested and modified independently
- New developers can understand the system without reverse engineering

## Performance Considerations

- `ApiClient` reuses HTTP connections via singleton pattern
- API calls include request/response logging in debug mode
- Complex workflows (like message sending) are atomic operations
- Error states are handled gracefully without partial updates

Remember: This API layer exists to provide a clean interface to a messy backend. Keep the complexity contained here so the rest of the application can stay simple and maintainable.