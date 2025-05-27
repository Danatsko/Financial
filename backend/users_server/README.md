# Users server

Users server - a server for managing users and achievements.

## API Reference

#### Registration user

```http
  POST /api/users/
```

|       Parameter       |   Type   | Location | Requirement |     Description      |
|:---------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|    `Authorization`    | `string` | `header` |  Required   | Gateway Bearer token |
|      `username`       | `string` |  `body`  |  Optional   |    User username     |
|        `email`        | `string` |  `body`  |  Required   |      User email      |
|      `password`       | `string` |  `body`  |  Required   |    User password     |
|       `balance`       | `float`  |  `body`  |  Required   |     User balance     |
|   `monthly_budget`    | `float`  |  `body`  |  Required   | User monthly budget  |

#### Social exchange token

```http
  POST /api/social/exchange-token/
```

|          Parameter           |   Type   | Location | Requirement |     Description      |
|:----------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|       `Authorization`        | `string` | `header` |  Required   | Gateway Bearer token |
|          `app_code`          | `string` |  `body`  |  Required   |       App code       |
|          `provider`          | `string` |  `body`  |  Required   |    Provider name     |

#### Get authenticated user

```http
  GET /api/users/me/
```

|                    Parameter                    |   Type   | Location | Requirement |     Description      |
|:-----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                 `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|             `X-User-Authorization`              | `string` | `header` |  Required   |  User Bearer token   |

#### Get authenticated user achievements

```http
  GET /api/achievements/
```

|                    Parameter                    |   Type   | Location | Requirement |     Description      |
|:-----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                 `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|             `X-User-Authorization`              | `string` | `header` |  Required   |  User Bearer token   |

#### Get social login url

```http
  GET /api/social/{provider}/login-url/
```

|                   Parameter                    |   Type   | Location | Requirement |     Description      |
|:----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|                   `provider`                   | `string` |  `path`  |  Required   |    Provider name     |

#### Generate app code

```http
  GET /api/social/generate-app-code/
```

|                    Parameter                    |   Type   | Location | Requirement |    Description    |
|:-----------------------------------------------:|:--------:|:--------:|:-----------:|:-----------------:|
|                 `Authorization`                 | `string` | `header` |  Required   | User Bearer token |

#### Update authenticated user

```http
  PATCH /api/users/me/
```

|                   Parameter                    |   Type   | Location | Requirement |     Description      |
|:----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|             `X-User-Authorization`             | `string` | `header` |  Required   |  User Bearer token   |
|                   `username`                   | `string` |  `body`  |  Optional   |    User username     |
|                    `email`                     | `string` |  `body`  |  Optional   |      User email      |
|                   `password`                   | `string` |  `body`  |  Optional   |    User password     |
|                   `balance`                    | `float`  |  `body`  |  Optional   |     User balance     |
|                `monthly_budget`                | `float`  |  `body`  |  Optional   | User monthly budget  |

#### Increment authenticated user achievement value

```http
  PATCH /api/achievements/increment_achievement_value/
```

|                   Parameter                    |   Type   | Location | Requirement |     Description      |
|:----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|             `X-User-Authorization`             | `string` | `header` |  Required   |  User Bearer token   |
|                   `category`                   | `string` |  `body`  |  Required   |    Category name     |

#### Delete authenticated user

```http
  DELETE /api/users/me/
```

|                    Parameter                    |   Type   | Location | Requirement |     Description      |
|:-----------------------------------------------:|:--------:|:--------:|:-----------:|:--------------------:|
|                 `Authorization`                 | `string` | `header` |  Required   | Gateway Bearer token |
|             `X-User-Authorization`              | `string` | `header` |  Required   |  User Bearer token   |

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`SECRET_KEY`

`DEBUG`

`ALLOWED_HOSTS`

`DATABASE_URL`

`GATEWAY_APPLICATION_CLIENT_IDS`

`USERS_APPLICATION_CLIENT_IDS`

`SOCIALACCOUNT_APPLICATION_CLIENT_ID`

## Developers

- [@Danatsko](https://github.com/Danatsko)