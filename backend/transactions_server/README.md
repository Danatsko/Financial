# Transactions server

Transactions server - a server for managing transactions.

## API Reference

#### Create transaction

```http
  POST /api/transactions/
```

|    Parameter     |   Type   | Location | Requirement |         Description         |
|:----------------:|:--------:|:--------:|:-----------:|:---------------------------:|
| `Authorization`  | `string` | `header` |  Required   |    Gateway Bearer token     |
|    `user_id`     | `string` |  `body`  |  Required   |           User id           |
|      `type`      | `string` |  `body`  |  Required   |      Transaction type       |
|     `amount`     | `float`  |  `body`  |  Required   |     Transaction amount      |
|     `title`      | `string` |  `body`  |  Required   |      Transaction title      |
| `payment_method` | `string` |  `body`  |  Optional   | Transaction payment method  |
|  `description`   | `string` |  `body`  |  Optional   |   Transaction description   |
|    `category`    | `string` |  `body`  |  Required   |    Transaction category     |
| `creation_date`  |  `date`  |  `body`  |  Required   |  Transaction creation date  |

#### Get transactions data

```http
  GET /api/transactions/get_transactions_data/
```

|    Parameter    |   Type   | Location | Requirement |      Description      |
|:---------------:|:--------:|:--------:|:-----------:|:---------------------:|
| `Authorization` | `string` | `header` |  Required   | Gateway Bearer token  |
|    `user_id`    | `string` | `query`  |  Required   |        User id        |
|  `start_date`   |  `date`  | `query`  |  Required   |      Start date       |
|   `end_date`    |  `date`  | `query`  |  Required   |       End date        |

#### Get analyse data

```http
  GET /api/transactions/get_analyse_data/
```

|    Parameter    |   Type   | Location | Requirement |      Description      |
|:---------------:|:--------:|:--------:|:-----------:|:---------------------:|
| `Authorization` | `string` | `header` |  Required   | Gateway Bearer token  |
|    `user_id`    | `string` | `query`  |  Required   |        User id        |
|  `start_date`   |  `date`  | `query`  |  Required   |      Start date       |
|   `end_date`    |  `date`  | `query`  |  Required   |       End date        |

#### Get monthly recommendations

```http
  GET /api/transactions/get_monthly_recommendations/
```

|     Parameter      |   Type   | Location | Requirement |      Description      |
|:------------------:|:--------:|:--------:|:-----------:|:---------------------:|
|  `Authorization`   | `string` | `header` |  Required   | Gateway Bearer token  |
|     `user_id`      | `string` | `query`  |  Required   |        User id        |
|  `monthly_budget`  | `float`  | `query`  |  Required   |    Monthly budget     |

#### Update transaction

```http
  PATCH /api/transactions/{transaction_id}/
```

|     Parameter     |   Type   | Location | Requirement |         Description         |
|:-----------------:|:--------:|:--------:|:-----------:|:---------------------------:|
|  `Authorization`  | `string` | `header` |  Required   |    Gateway Bearer token     |
| `transaction_id`  | `string` |  `path`  |  Required   |       Transaction id        |
|     `user_id`     | `string` | `query`  |  Required   |           User id           |
|      `type`       | `string` |  `body`  |  Optional   |      Transaction type       |
|     `amount`      | `float`  |  `body`  |  Optional   |     Transaction amount      |
|      `title`      | `string` |  `body`  |  Optional   |      Transaction title      |
| `payment_method`  | `string` |  `body`  |  Optional   | Transaction payment method  |
|   `description`   | `string` |  `body`  |  Optional   |   Transaction description   |
|    `category`     | `string` |  `body`  |  Optional   |    Transaction category     |
|  `creation_date`  |  `date`  |  `body`  |  Optional   |  Transaction creation date  |

#### Delete transaction

```http
  DELETE /api/transactions/{transaction_id}/
```

|     Parameter     |   Type   | Location | Requirement |        Description         |
|:-----------------:|:--------:|:--------:|:-----------:|:--------------------------:|
|  `Authorization`  | `string` | `header` |  Required   |    Gateway Bearer token    |
| `transaction_id`  | `string` |  `path`  |  Required   |       Transaction id       |
|     `user_id`     | `string` | `query`  |  Required   |          User id           |

#### Delete all user transactions

```http
  DELETE /api/transactions/delete_all_user_transactions/
```

|     Parameter     |   Type   | Location | Requirement |        Description         |
|:-----------------:|:--------:|:--------:|:-----------:|:--------------------------:|
|  `Authorization`  | `string` | `header` |  Required   |    Gateway Bearer token    |
| `transaction_id`  | `string` |  `path`  |  Required   |       Transaction id       |
|     `user_id`     | `string` | `query`  |  Required   |          User id           |

## Environment Variables

To run this project, you will need to add the following environment variables to your .env file

`SECRET_KEY`

`DEBUG`

`ALLOWED_HOSTS`

`DATABASE_URL`

`GATEWAY_APPLICATION_CLIENT_IDS`

## Developers

- [@Danatsko](https://github.com/Danatsko)