# Gateway server

Gateway server - a server for acting as the central entry point for all client requests. 
It's responsible for routing requests to the appropriate services, and ensuring the overall security and stability of the API.

## API Reference

### Users reference

#### Registration user

```http
  POST /api/users/registration/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|      `username`      | `string` |  `body`  |  Optional   |    User username    |
|       `email`        | `string` |  `body`  |  Required   |     User email      |
|      `password`      | `string` |  `body`  |  Required   |    User password    |
|      `balance`       | `float`  |  `body`  |  Required   |    User balance     |
|   `monthly_budget`   | `float`  |  `body`  |  Required   | User monthly budget |

#### Login user

```http
  POST /api/users/login/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|       `email`        | `string` |  `body`  |  Required   |     User email      |
|      `password`      | `string` |  `body`  |  Required   |    User password    |

#### Logout user

```http
  POST /api/users/logout/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|   `Authorization`    | `string` | `header` |  Required   |  User Bearer token  |

#### Refresh token

```http
  POST /api/users/refresh-token/
```

|      Parameter       |   Type   | Location | Requirement |    Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:------------------:|
|   `refresh_token`    | `string` |  `body`  |  Required   | User refresh token |

#### Social exchange token

```http
  POST /api/users/social/exchange-token/
```

|       Parameter        |   Type   | Location | Requirement |  Description  |
|:----------------------:|:--------:|:--------:|:-----------:|:-------------:|
|       `app_code`       | `string` |  `body`  |  Required   |   App code    |
|       `provider`       | `string` |  `body`  |  Required   | Provider name |

#### Get authenticated user

```http
  GET /api/users/me/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|   `Authorization`    | `string` | `header` |  Required   |  User Bearer token  |

#### Get authenticated user achievements

```http
  GET /api/users/achievements/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|   `Authorization`    | `string` | `header` |  Required   |  User Bearer token  |

#### Get social login url

```http
  GET /api/users/social/{provider}/login-url/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|      `provider`      | `string` |  `path`  |  Required   |    Provider name    |

#### Update authenticated user

```http
  PATCH /api/users/me/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|   `Authorization`    | `string` | `header` |  Required   |  User Bearer token  |
|      `username`      | `string` |  `body`  |  Optional   |    User username    |
|       `email`        | `string` |  `body`  |  Optional   |     User email      |
|      `password`      | `string` |  `body`  |  Optional   |    User password    |
|      `balance`       | `float`  |  `body`  |  Optional   |    User balance     |
|   `monthly_budget`   | `float`  |  `body`  |  Optional   | User monthly budget |

#### Delete authenticated user

```http
  DELETE /api/users/me/
```

|      Parameter       |   Type   | Location | Requirement |     Description     |
|:--------------------:|:--------:|:--------:|:-----------:|:-------------------:|
|   `Authorization`    | `string` | `header` |  Required   |  User Bearer token  |

### Transactions reference

#### Create transaction

```http
  POST /api/transactions/
```

|      Parameter      |   Type   | Location | Requirement |        Description         |
|:-------------------:|:--------:|:--------:|:-----------:|:--------------------------:|
|   `Authorization`   | `string` | `header` |  Required   |     User Bearer token      |
|       `type`        | `string` |  `body`  |  Required   |      Transaction type      |
|      `amount`       | `float`  |  `body`  |  Required   |     Transaction amount     |
|       `title`       | `string` |  `body`  |  Required   |     Transaction title      |
|  `payment_method`   | `string` |  `body`  |  Required   | Transaction payment method |
|    `description`    | `string` |  `body`  |  Required   |  Transaction description   |
|     `category`      | `string` |  `body`  |  Required   |    Transaction category    |
|   `creation_date`   |  `date`  |  `body`  |  Required   | Transaction creation date  |

#### Get transactions data

```http
  GET /api/transactions/get_transactions_data/
```

|     Parameter      |   Type   | Location | Requirement |        Description        |
|:------------------:|:--------:|:--------:|:-----------:|:-------------------------:|
|  `Authorization`   | `string` | `header` |  Required   |     User Bearer token     |
|    `start_date`    |  `date`  | `query`  |  Required   |        Start date         |
|     `end_date`     |  `date`  | `query`  |  Required   |         End date          |

#### Get analyse data

```http
  GET /api/transactions/get_analyse_data/
```

|     Parameter      |   Type   | Location | Requirement |        Description        |
|:------------------:|:--------:|:--------:|:-----------:|:-------------------------:|
|  `Authorization`   | `string` | `header` |  Required   |     User Bearer token     |
|    `start_date`    |  `date`  | `query`  |  Required   |        Start date         |
|     `end_date`     |  `date`  | `query`  |  Required   |         End date          |

#### Get monthly recommendations

```http
  GET /api/transactions/get_monthly_recommendations/
```

|     Parameter      |   Type   | Location | Requirement |       Description        |
|:------------------:|:--------:|:--------:|:-----------:|:------------------------:|
|  `Authorization`   | `string` | `header` |  Required   |    User Bearer token     |
|    `start_date`    |  `date`  | `query`  |  Required   |        Start date        |
|  `monthly_budget`  | `float`  | `query`  |  Required   |      Monthly budget      |

#### Update transaction

```http
  PATCH /api/transactions/{transaction_id}/
```

|           Parameter            |   Type   | Location | Requirement |        Description         |
|:------------------------------:|:--------:|:--------:|:-----------:|:--------------------------:|
|        `Authorization`         | `string` | `header` |  Required   |     User Bearer token      |
|        `transaction_id`        | `string` |  `path`  |  Required   |       Transaction id       |
|             `type`             | `string` |  `body`  |  Optional   |      Transaction type      |
|            `amount`            | `float`  |  `body`  |  Optional   |     Transaction amount     |
|            `title`             | `string` |  `body`  |  Optional   |     Transaction title      |
|        `payment_method`        | `string` |  `body`  |  Optional   | Transaction payment method |
|         `description`          | `string` |  `body`  |  Optional   |  Transaction description   |
|           `category`           | `string` |  `body`  |  Optional   |    Transaction category    |
|        `creation_date`         |  `date`  |  `body`  |  Optional   | Transaction creation date  |

#### Delete transaction

```http
  DELETE /api/transactions/{transaction_id}/
```

|            Parameter            |   Type   | Location | Requirement |    Description    |
|:-------------------------------:|:--------:|:--------:|:-----------:|:-----------------:|
|         `Authorization`         | `string` | `header` |  Required   | User Bearer token |
|        `transaction_id`         | `string` |  `path`  |  Required   |  Transaction id   |

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`USERS_SERVER_URL`

`USERS_SERVER_GATEWAY_APPLICATION_CLIENT_ID`

`USERS_SERVER_GATEWAY_APPLICATION_CLIENT_SECRET`

`USERS_SERVER_USERS_APPLICATION_CLIENT_ID`

`USERS_SERVER_USERS_APPLICATION_CLIENT_SECRET`

`USERS_SERVER_GATEWAY_SCOPES`

`USERS_SERVER_USERS_SCOPES`

`TRANSACTIONS_SERVER_URL`

`TRANSACTIONS_SERVER_GATEWAY_APPLICATION_CLIENT_ID`

`TRANSACTIONS_SERVER_GATEWAY_APPLICATION_CLIENT_SECRET`

`TRANSACTIONS_SERVER_GATEWAY_SCOPES`

`REDIS_SERVER_URL`

## Developers

- [@Danatsko](https://github.com/Danatsko)