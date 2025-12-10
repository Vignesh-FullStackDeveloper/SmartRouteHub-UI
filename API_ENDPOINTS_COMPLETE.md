# Complete API Endpoints Mapping

## Authentication ✅
- `POST /api/auth/login` - Login (email, password, optional organizationCode)
- `GET /api/auth/verify` - Verify token (requires Bearer token)
- `POST /api/auth/logout` - Logout (requires Bearer token)

## Organizations ✅
- `POST /api/organizations` - Create (public, no auth)
- `GET /api/organizations/:id` - Get by ID (requires auth)
- `PUT /api/organizations/:id` - Update (requires auth)

**Note:** Need endpoint to get by code - may need to use GET with code as ID or add new endpoint

## Students ✅
- `POST /api/students` - Create (requires auth)
- `GET /api/students` - Get all (query: bus_id, route_id, class_grade, is_active)
- `GET /api/students/:id` - Get by ID
- `PUT /api/students/:id` - Update
- `DELETE /api/students/:id` - Delete
- `GET /api/students/:id/pickup-location` - Get pickup location

## Buses ✅
- `POST /api/buses` - Create
- `GET /api/buses` - Get all (query: is_active, driver_id)
- `GET /api/buses/:id` - Get by ID
- `PUT /api/buses/:id` - Update
- `DELETE /api/buses/:id` - Delete
- `POST /api/buses/:id/assign-driver` - Assign driver

## Routes ✅
- `POST /api/routes` - Create (with stops array)
- `GET /api/routes` - Get all (query: is_active, bus_id)
- `GET /api/routes/:id` - Get by ID (includes stops)
- `PUT /api/routes/:id` - Update (can update stops)
- `DELETE /api/routes/:id` - Delete
- `POST /api/routes/:id/assign-students` - Assign students

## Drivers ✅
- `POST /api/drivers` - Create
- `GET /api/drivers` - Get all (query: is_active, has_bus)
- `GET /api/drivers/:id` - Get by ID
- `PUT /api/drivers/:id` - Update
- `GET /api/drivers/:id/schedule` - Get driver schedule

## Trips ✅
- `POST /api/trips/start` - Start trip
- `POST /api/trips/:id/location` - Update location
- `POST /api/trips/:id/end` - End trip
- `GET /api/trips/active` - Get active trips
- `GET /api/trips/:id` - Get trip by ID

## Notifications ✅
- `GET /api/notifications` - Get notifications (query: unread_only, limit, offset) - Parent only
- `GET /api/notifications/unread-count` - Get unread count - Parent only
- `PATCH /api/notifications/:id/read` - Mark as read - Parent only
- `PATCH /api/notifications/read-all` - Mark all as read - Parent only
- `GET /api/notifications/stream` - SSE stream - Parent only

## Users ✅
- `POST /api/users` - Create user (admin/superadmin only)
- `GET /api/users` - Get all (query: role, is_active)
- `GET /api/users/:id` - Get by ID
- `PUT /api/users/:id` - Update

## Maps ✅
- `POST /api/maps/route/calculate` - Calculate route
- `POST /api/maps/geocode` - Geocode address
- `POST /api/maps/reverse-geocode` - Reverse geocode

## Analytics ✅
- `GET /api/analytics/students/:id/travel-history` - Student travel history
- `GET /api/analytics/buses/:id/travel-history` - Bus travel history
- `GET /api/analytics/drivers/:id/travel-history` - Driver travel history
- `GET /api/analytics/dashboard` - Dashboard insights

## Assignments ✅
- `POST /api/assignments/students-to-route` - Assign students to route
- `POST /api/assignments/students-to-bus` - Assign students to bus
- `GET /api/assignments/route/:id/students` - Get route assignments
- `GET /api/assignments/bus/:id/students` - Get bus assignments

## Subscriptions ✅
- `POST /api/subscriptions` - Create subscription
- `GET /api/subscriptions/student/:id` - Get student subscriptions
- `GET /api/subscriptions/student/:id/active` - Get active subscription
- `PUT /api/subscriptions/:id` - Update subscription
- `GET /api/subscriptions/expiring` - Get expiring subscriptions

## All endpoints require Bearer token in Authorization header (except login and create org)

