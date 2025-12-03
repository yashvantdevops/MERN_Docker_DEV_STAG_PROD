import React from "react";

export default class AddTodo extends React.Component {
  handleSubmit = (e) => {
    e.preventDefault();
    const input = e.target.elements.value;
    if (input && input.value && input.value.trim().length > 0) {
      this.props.handleAddTodo(input.value.trim());
      e.target.reset();
    }
  };

  render() {
    return (
      <form
        noValidate
        onSubmit={this.handleSubmit}
        className="new-todo form-group"
      >
        <input
          type="text"
          name="value"
          required
          minLength={1}
          className="form-control"
        />
        <button className="btn btn-primary" type="submit">
          Add Todo
        </button>
      </form>
    );
  }
}
