/**
 * Created by Syed Afzal
 */
const express = require("express");
const serverResponses = require("../utils/helpers/responses");
const messages = require("../config/messages");
const { Todo } = require("../models/todos/todo");

const routes = (app) => {
  const router = express.Router();

  // Create a new todo
  router.post("/todos", (req, res) => {
    const { text } = req.body;

    if (!text) {
      return serverResponses.sendError(res, messages.IN_COMPLETE_REQUEST);
    }

    const todo = new Todo({ text });

    todo
      .save()
      .then((result) => {
        serverResponses.sendSuccess(res, messages.SUCCESSFUL, result);
      })
      .catch((e) => {
        serverResponses.sendError(res, messages.BAD_REQUEST, e);
      });
  });

  // Get all todos
  router.get("/todos", (req, res) => {
    Todo.find({}, { __v: 0 })
      .then((todos) => {
        serverResponses.sendSuccess(res, messages.SUCCESSFUL, todos);
      })
      .catch((e) => {
        serverResponses.sendError(res, messages.BAD_REQUEST, e);
      });
  });

  // Root API route - return all todos (used by frontend GET `${API_ROOT}`)
  router.get('/', (req, res) => {
    Todo.find({}, { __v: 0 })
      .then((todos) => {
        serverResponses.sendSuccess(res, messages.SUCCESSFUL, todos);
      })
      .catch((e) => {
        serverResponses.sendError(res, messages.BAD_REQUEST, e);
      });
  });

  // Mount the router with the /api prefix
  app.use("/api", router);
};

module.exports = routes;
