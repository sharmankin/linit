import platform

from fastapi import FastAPI, Depends, HTTPException, status, Request, Response, Query

import aiopg
import jinja2

# if platform.system() == 'Windows':
#     import asyncio
#     from asyncio import WindowsSelectorEventLoopPolicy
#
#     asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())

# noinspection SpellCheckingInspection
app = FastAPI(
    docs_url='/34d5dcdba59a18c7f3cdb57dd8a83437/docs',
    openapi_url='/34d5dcdba59a18c7f3cdb57dd8a83437/openapi.json'
)


# noinspection SpellCheckingInspection
@app.on_event("startup")
async def _startup():
    app.state.pool = await aiopg.create_pool(
        'host=172.16.100.150 user=me dbname=me',
        **{
            'keepalives': '1',
            'keepalives_idle': '60',
            'keepalives_interval': '2',
            'keepalives_count': '3',
            'connect_timeout': '2'
        }
    )


@app.on_event('shutdown')
async def _shutdown():
    app.state.pool.close()
    await app.state.pool.wait_closed()


if __name__ == '__main__':
    import uvicorn

    uvicorn.run('__main__:app', reload=True)

