import express, { Application } from 'express'
import cors from 'cors'
import morgan from 'morgan'
import bodyParser from 'body-parser'
require('dotenv').config()
require('./database')
import swaggerUi from 'swagger-ui-express'
import swaggerDocument from './swagger.json';
import agentRoute from './routes/agent.routes';
import adminRoute from './routes/admin.routes';
import superAdminRoute from './routes/superadmin.routes';
import userRoute from './routes/user.routes';