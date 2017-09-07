# Haskdragon

Aim of this Repository is getting to understand some Yesod: a web framework for Haskell language

## Try this web app:

- Install Redis

  - Unix: [official website](https://redis.io/)
  - OXS: [medium post](https://medium.com/@petehouston/install-and-config-redis-on-mac-os-x-via-homebrew-eb8df9a4f298)
  - Windows: [win-porting](https://github.com/ServiceStack/redis-windows)

- Run redis-server


```bash
redis-server
```



- Install Stack
```bash
git clone <this url>
cd <repo-directory>
stack setup
stack build
stack exec haskdragon-exe
```



- Enjoy in your browser or in Postman

For instance, head to: 

[localhost:3000](http://localhost:3000)



## Story of this project

### [Stack Setup](./tutorial/Stack.md)

Setting up project with Stack

### [Redis](./tutorial/Redis.md)
Configure Hedis to use Redis inside project, use Hedis wit Yesod

### [Subsites](./tutorial/Subsites.md)
Improve code modularity using subsites

### [Editor](./tutorial/Editor.md)
My (personal and opinated) answer to "What is the best editor for coding Haskell"

### [Docker](./tutorial/Docker.md)

My road towards continuos integration, first step is building this project using docker