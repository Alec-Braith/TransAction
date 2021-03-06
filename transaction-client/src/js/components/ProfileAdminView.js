import React, { Component } from 'react';
import ProfileOfficeForm from './ProfileOfficeForm.js';
import _ from 'lodash';

import { Link } from 'react-router-dom';
import { connect } from 'react-redux';
import { Container, Spinner, Button } from 'reactstrap';
import {
  fetchCurrentUser,
  fetchTeam,
  editUser,
  fetchRegions,
  fetchAllUserScores,
  fetchEvents,
  fetchRoles,
  fetchUser,
} from '../actions';
import DescriptionForm from './DescriptionForm';

class Profile extends Component {
  state = { loading: true, modal: false, currentTeam: {}, userRole: '' };
  toggleSpinner = () => {
    this.setState(prevState => ({
      loading: !prevState.loading,
    }));
  };

  toggle = () => {
    this.setState(prevState => ({
      modal: !prevState.modal,
    }));
  };

  decideRender() {
    if (this.state.loading) {
      //console.log('spin');
      return (
        <div className="col-1 offset-6">
          <Spinner color="primary" style={{ width: '5rem', height: '5rem' }} />
        </div>
      );
    } else {
      return this.userInfo();
    }
  }

  findRole(userRoleId) {
    //console.log(this.props.roles[userRoleId].name);
    this.setState({ userRole: this.props.roles[userRoleId].name });
    // this.props.roles.foreach(role => {
    // console.log('checking ', role.name);
    // if (userRoleId === role.id) {
    //   console.log('This user is a ', role.name);
    //   this.setState({ userRole: role.name });
    // }
    //  });
  }

  componentDidMount() {
    // this.toggleSpinner();
    this.props
      .fetchUser(this.props.userId)
      .then(() => {
        const teamId = this.props.user.teamId;
        Promise.all([this.props.fetchRegions(), this.props.fetchTeam(this.props.user.teamId)])
          .then(() => {
            this.setState({ currentTeam: this.props.team[teamId] });
            this.toggleSpinner();
          })
          .catch(() => {
            console.log('ERROR');
            this.toggleSpinner();
          });
      })
      .catch(() => {
        this.toggleSpinner();
      });
  }

  onSubmit = formValues => {
    //console.log('passed in ', formValues);
    const userObj = { ...this.props.user, ...formValues };
    //console.log('now contain ', userObj);
    this.props.editUser(userObj, 'me');
  };

  leaveTeam = () => {
    const leaveAlert = window.confirm('Do you really want to leave the team?');
    if (leaveAlert === true) {
      const team = { teamId: null };
      this.onSubmit(team);
    }
  };

  //TODO Button logic
  printTeam = () => {
    if (this.props.user.teamId !== null) {
      return (
        <h3 className="mt-3">
          Team: {this.state.currentTeam.name}
          <Link to="/team">
            <Button color="primary" className="ml-3 mb-2">
              Visit Team
            </Button>
          </Link>
          <Button color="secondary" className="ml-3 mb-2" onClick={this.leaveTeam}>
            {' '}
            Remove From Team
          </Button>
        </h3>
      );
    } else {
      return <h3 className="mt-3">Team: No Team!</h3>;
    }
  };

  userInfo() {
    return (
      <div>
        <h3>
          Name: {this.props.user.fname} {this.props.user.lname}{' '}
        </h3>
        <h3>
          <ProfileOfficeForm
            initialValues={_.pick(this.props.user, 'regionId')}
            userRegion={this.props.user.regionId}
            regions={this.props.regions}
            onSubmit={this.onSubmit}
          />
        </h3>
        {this.printTeam()}
        <DescriptionForm initialValues={_.pick(this.props.user, 'description')} onSubmit={this.onSubmit} />
      </div>
    );
  }

  render() {
    return (
      <Container>
        <div>{this.decideRender()}</div>
      </Container>
    );
  }
}

const mapStateToProps = state => {
  return {
    currentUser: state.currentUser,
    user: state.users,
    team: state.team,
    regions: Object.values(state.regions),
    allUserScores: Object.values(state.allUserScores),
    events: Object.values(state.events),
    roles: state.roles,
  };
};

export default connect(
  mapStateToProps,
  { fetchCurrentUser, fetchUser, fetchTeam, editUser, fetchRegions, fetchAllUserScores, fetchEvents, fetchRoles }
)(Profile);
