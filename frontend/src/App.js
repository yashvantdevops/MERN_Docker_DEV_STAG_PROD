import React from "react";
import axios from "axios";
import "./App.scss";
import AddTodo from "./components/AddTodo";
import TodoList from "./components/TodoList";

// Read API base from env (set in .env.dev / docker-compose)
let API_BASE_URL = process.env.REACT_APP_API_URL;
const API_PREFIX = process.env.REACT_APP_API_PREFIX || "/api";

// Runtime fallback logic:
// - If the browser is on localhost, use localhost:5000 (accessible from host).
// - Otherwise use build-time REACT_APP_API_URL or docker service DNS.
if (typeof window !== "undefined") {
  const host = window.location.hostname;
  const isLocalhost = host === "localhost" || host === "127.0.0.1" || host === "0.0.0.0";

  if (isLocalhost) {
    // Browser on host localhost: use localhost backend
    API_BASE_URL = `http://${host}:5000`;
    console.log("[API] Running on localhost, using API:", API_BASE_URL);
  } else if (!API_BASE_URL) {
    // Browser not on localhost and no build-time URL: use docker DNS
    API_BASE_URL = "http://backend-api-dev:5000";
    console.log("[API] Running in container, using docker DNS:", API_BASE_URL);
  } else {
    console.log("[API] Using build-time API URL:", API_BASE_URL);
  }
} else {
  // Server-side or no window object
  API_BASE_URL = API_BASE_URL || "http://backend-api-dev:5000";
  console.log("[API] Server-side rendering, using:", API_BASE_URL);
}

const API_ROOT = `${API_BASE_URL}${API_PREFIX}`;
console.log("[API] Final API_ROOT:", API_ROOT);

export default class App extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      todos: [],
    };
  }

  componentDidMount() {
    axios
      .get(`${API_ROOT}`)
      .then((response) => {
        this.setState({
          todos: response.data.data,
        });
      })
      .catch((e) => console.log("Error : ", e));
  }

  handleAddTodo = (value) => {
    axios
      .post(`${API_ROOT}/todos`, { text: value })
      .then((response) => {
        this.setState({
          todos: [...this.state.todos, response.data.data],
        });
      })
      .catch((e) => console.log("Error : ", e));
  };

  render() {
    return (
      <div className="App container">
        <div className="container-fluid">
          <div className="row">
            <div className="col-xs-12 col-sm-8 col-md-8 offset-md-2">
              <h1>Todos</h1>
              <div className="todo-app">
                <AddTodo handleAddTodo={this.handleAddTodo} />
                <TodoList todos={this.state.todos} />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
