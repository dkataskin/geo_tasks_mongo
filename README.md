# GeoTasks

Implementation of the test task: https://github.com/netronixgroup/geo-tasks using Elixir, Phoenix and MongoDB

## Additional assumptions:
* a driver can have only 1 task in-progress
* state changes in one direction `created` –> `assigned` –> `completed` only
* list operation returns tasks with status 'created'

## Setup:

Prerequisites: Elixir 1.7, MongoDB 3.6.x

1. `mix deps.get`, `mix compile`
2. Run MongoDB v3.6.x server and modify connection string in `dev.exs` if needed
   default value is `"mongodb://localhost:27017/geo_tasks_dev?connectTimeoutMS=10000"`. 
   The mongodb user should have rights to create indexes and collections.
3. Start Phoenix server `iex -S mix phx.server`

The app will apply database migrations on start and will create a number of users for drivers and managers.

## API:

API port is 4000, all responses follow the same structure. If a request completed successfully:
```
{
  "success": true,
  "data": {...}
}
```
In case of error(s):

```
{
  "success": false,
  "errors": {...},
}

```
All requests require a `token` parameter with a valid token as value to be passed.

### Admin API:

To ease testing there is an endpoint that returns an access token for a random user with the specified role (`driver` or `manager`):

```
GET http://localhost:4000/admin/users/{role}/random/access_token
```
Examples:

Request
```
http http://localhost:4000/admin/users/driver/random/access_token
```

Response:
```
{
    "data": "3eaecde0ece46c4dd6779a2e3319282d3e03c373",
    "success": true
}
```

Request
```
http http://localhost:4000/admin/users/manager/random/access_token
```

Response:
```
{
    "data": "ab7c8fa0e218b9080b97eade7f0641642020fe20",
    "success": true
}
```

### User API:

#### Get Task
Returns a task by its id, avalailable for roles `driver`, `manager`:
```
GET http://localhost:4000/api/v1/tasks/{task_id}?token={access_token}
```
Parameters:
* task_id - required, task id
* access_token - required, access token

Examples:
```
http http://localhost:4000/api/v1/tasks/30f86990-98d6-11e9-9076-72000070bc70?token=ab7c8fa0e218b9080b97eade7f0641642020fe20
```

Response:
```
{
    "data": {
        "created": "2019-06-27T12:22:12.352Z",
        "delivery": {
            "lat": 20.2,
            "lon": 10.1
        },
        "id": "30f86990-98d6-11e9-9076-72000070bc70",
        "pickup": {
            "lat": 53.19,
            "lon": 45.01
        },
        "status": "completed"
    },
    "success": true
}
```

#### Create Task
Creates a new task, available for role `manager`:

```
POST http://localhost:4000/api/v1/tasks?token={access_token}
```
Body:
```
{
  "pickup": {pickup_loc},
  "delivery": {delivery_loc}
}
```

where location is a JSON object:
```
{
    "lon": {longitude},
    "lat": {latitude}
  }
```
* Valid longitude values are between -180 and 180, both inclusive
* Valid latitude values are between -90 and 90, both inclusive

Parameters:
* pickup_loc - required, pickup location
* delivery_loc - required, delivery location
* access_token - required, access token

Examples:

```
http POST http://localhost:4000/api/v1/tasks?token=ba3372031c3938185b03f4486d686961fdef41c5
```

Body:
```
{
  "pickup": {
    "lon": 45.01,
    "lat": 53.19
  },
  "delivery": {
    "lon": 10.1,
    "lat": 20.2
  }
}
```

Response:
```
{
  "data": {
    "created": "2019-06-27T12:22:12.352Z",
    "delivery": {
      "lat": 20.2,
      "lon": 10.1
    },
    "id": "30f86990-98d6-11e9-9076-72000070bc70",
    "pickup": {
      "lat": 53.19,
      "lon": 45.01
    },
    "status": "created"
  },
  "success": true
}
```

#### List Tasks
Returns list of tasks sorted by distance from the specified location,available for roles `driver`, `manager`:

```
GET http://localhost:4000/api/v1/tasks?token={access_token}&location={location}&max_distance={max_distance}&limit={limit}
```
where `{location}` is string which is made of pair of coordinates: `{long},{lat}`

Parameters:
* access_token - required, access token
* location - required, location which will be used to return tasks sorted by proximity
* max_distance - optional, max distance in meters, default value is 1 000 000 meters
* limit - optional, limit of records in the response, default value is 100

Examples:
```
http http://localhost:4000/api/v1/tasks?token=0f3440ae3af5c8f090b7d7f76f0d74a03f3748eb&location=45.17,53.78&max_distance=300000
```

Response:
```
{
  "data": [
    {
      "data": {
        "created": "2019-06-26T15:35:54.470Z",
        "delivery": {
          "lat": 20.2,
          "lon": 10.1
        },
        "id": "15e12eca-9828-11e9-88a7-72000070bc70",
        "pickup": {
          "lat": 54.18,
          "lon": 45.18
        },
        "status": "created"
      },
      "success": true
    },
    {
      "data": {
        "created": "2019-06-26T15:36:13.187Z",
        "delivery": {
          "lat": 20.2,
          "lon": 10.1
        },
        "id": "21092ad2-9828-11e9-b774-72000070bc70",
        "pickup": {
          "lat": 53.19,
          "lon": 45.01
        },
        "status": "created"
      },
      "success": true
    },
    {
      "data": {
        "created": "2019-06-26T15:35:32.149Z",
        "delivery": {
          "lat": 20.2,
          "lon": 10.1
        },
        "id": "08933ee8-9828-11e9-aa41-72000070bc70",
        "pickup": {
          "lat": 56.32,
          "lon": 44
        },
        "status": "created"
      },
      "success": true
    }
  ],
  "success": true
}
```

#### Assign Task
Assigns specified task to the driver, available for roles `driver`:
```
POST http://localhost:4000/api/v1/tasks/{task_id}/assign
```

Parameters:
* task_id - required, task id
* access_token - required, access token

Examples:
```
http POST http://localhost:4000/api/v1/tasks/30f86990-98d6-11e9-9076-72000070bc70/assign?token=0f3440ae3af5c8f090b7d7f76f0d74a03f3748eb
```

Response:
```
{
  "data": {
    "created": "2019-06-27T12:22:12.352Z",
    "delivery": {
      "lat": 20.2,
      "lon": 10.1
    },
    "id": "30f86990-98d6-11e9-9076-72000070bc70",
    "pickup": {
      "lat": 53.19,
      "lon": 45.01
    },
    "status": "assigned"
  },
  "success": true
}
```

#### Complete Task
Completes specified task, available for roles `driver`:
```
POST http://localhost:4000/api/v1/tasks/{task_id}/complete
```

Parameters:
* task_id - required, task id
* access_token - required, access token

Examples:
```
http POST http://localhost:4000/api/v1/tasks/30f86990-98d6-11e9-9076-72000070bc70/complete?token=0f3440ae3af5c8f090b7d7f76f0d74a03f3748eb
```

Response:
```
{
  "data": {
    "created": "2019-06-27T12:22:12.352Z",
    "delivery": {
      "lat": 20.2,
      "lon": 10.1
    },
    "id": "30f86990-98d6-11e9-9076-72000070bc70",
    "pickup": {
      "lat": 53.19,
      "lon": 45.01
    },
    "status": "completed"
  },
  "success": true
}
```