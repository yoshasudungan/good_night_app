# README

This README documents the steps necessary to get the "Good Night" application up and running.

## Application Overview

The "Good Night" application allows users to track their sleep patterns by recording when they go to bed and when they wake up. The application provides the following RESTful APIs:

1. **Clock In Operation**: Record the time a user goes to bed or wakes up and return all clocked-in times, ordered by creation time.
2. **Follow/Unfollow Users**: Allow users to follow and unfollow other users.
3. **View Sleep Records**: Retrieve the sleep records of all users that a user follows from the previous week, sorted by the duration of sleep.

### Example Response for Sleep Records
```json
[
    { "record": "record 1 from user A" },
    { "record": "record 2 from user B" },
    { "record": "record 3 from user A" },
    ...
]
```

## Requirements

- Implement the model, database migrations, schema, and JSON API.
- Write tests for the APIs.
- Ensure the system can handle a high volume of data and concurrent requests.
- Assume users have only two fields: "id" and "name".

## Technologies Used

- **Rails**: The web application framework.
- **MySQL**: The database management system.

## Setup Instructions

### Ruby Version

Specify the Ruby version required for the application.

### System Dependencies

List any system dependencies required to run the application.

### Configuration

Provide configuration details for the application.

### Database Creation

Instructions to create the database.

### Database Initialization

Steps to initialize the database.

### How to Run the Test Suite

Instructions to run the test suite.

### Services

Details about job queues, cache servers, search engines, etc.

### Deployment Instructions

Steps to deploy the application.

### Additional Information
- **Cache in `sleep_records_controller`**:
    - The `sleep_records_controller` uses caching to store frequently accessed data, reducing the load on the database and improving response times. This is particularly useful for the "View Sleep Records" API, where the same data might be requested multiple times within a short period.

- **Archiving Task**: 
    - An archiving task is scheduled to run manually, which identifies and removes old, unused data from the database. This helps in maintaining optimal database performance and ensures that the application remains responsive even as the volume of data grows.
