import React, { Component } from 'react';
import { Form, Input, Button } from 'reactstrap';
import { Field, reduxForm } from 'redux-form';
import { connect } from 'react-redux';
class DescriptionForm extends Component {
  componentDidMount() {
    this.props.initialize(this.props.initialValues);
  }
  renderInput = ({ input, type }) => {
    return <Input type={type} {...input} autoComplete="off" />;
  };

  onSubmit = formValues => {
    //console.log('Attempting to edit description!');
    //console.log(formValues);
    this.props.onSubmit(formValues);
  };
  render() {
    return (
      <div>
        <h3>Description: </h3>
        <Form onSubmit={this.props.handleSubmit(this.onSubmit)}>
          <Field name="description" component={this.renderInput} type="textarea" />
          <Button color="primary" className="right">
            Save Changes
          </Button>
        </Form>
      </div>
    );
  }
}

const form = reduxForm({
  form: 'profileDescriptionForm',
  enableReinitialize: true,
})(DescriptionForm);

const mapStateToProps = (state, ownProps) => {
  return {
    initialValues: state.users[ownProps.userid],
  };
};

export default connect(
  mapStateToProps,
  null
)(form);
