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
    - An archiving task is scheduled to run manually, which identifies and removes old, unused data from the database. This helps in maintaining optimal database performance and ensures that the application remains responsive even as the volume of data grows. (data retaining / at least able to identify between cold and hot data will have big impact to the stability of the apps later in the future)
- **Future Considerations**:
    - **Caching Strategy**: If the application is deployed to multiple instances or requires more performance gain, consider using Redis for caching. Redis is an in-memory data structure store that can significantly improve the performance of the application by reducing the load on the database. However, it comes with an additional cost. While Redis might be relatively inexpensive, the balance between performance gain and the added cost should be carefully discussed and evaluated.
    - **Background Processing**:As the number of users and the volume of data grow, write performance may degrade. To address this, consider implementing background processing using tools like Sidekiq. Sidekiq allows you to handle long-running tasks asynchronously, improving the responsiveness of the application. For example, you can offload tasks such as recording sleep data or updating follower information to background jobs, ensuring that the main application remains responsive to user requests.
    - **Microservices Implementation**:If Sidekiq is no longer sufficient to handle the background processing needs, it might be a good plan to implement microservices in the future. This could involve using message brokers like Kafka or RabbitMQ to manage communication between services. However, this approach requires a detailed discussion related to business requirements and user behavior. It's important to find a balance between time, cost, and quality when considering this transition. Microservices can offer significant benefits in terms of scalability and maintainability, but they also introduce complexity and require careful planning and execution.
    - **Data Partitioning**: As the application scales and the volume of data grows, it may become necessary to partition the database to maintain performance. This involves dividing the database into smaller, more manageable pieces, which can be distributed across multiple servers. However, this is a major refactor and should be approached with a clear understanding of user behavior and data growth patterns.
    - **Shopify Pods Architecture**: For large-scale applications with rapid data growth, adopting an architecture similar to Shopify's pods can be beneficial. This involves creating isolated units (pods) that contain a subset of the application's data and functionality. While this approach can significantly improve scalability, it requires careful planning and can be costly to implement.