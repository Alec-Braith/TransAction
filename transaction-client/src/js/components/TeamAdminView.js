import React, { Component } from 'react';
import { Spinner, Button, Table } from 'reactstrap';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux';
import _ from 'lodash';
import { fetchCurrentUser, fetchTeam, editTeam, fetchUsers, fetchRoles, fetchCurrentTeam, editUser } from '../actions';
import DescriptionForm from './DescriptionForm';
import TitleForm from './TitleForm';

class TeamAdminView extends Component {
  state = { loading: true, modal: false, userRole: '' };
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

  //TODO could be taken out into its own component?
  loading() {
    if (this.state.loading) {
      //console.log('spin');
      return (
        <div className="col-1 offset-6">
          <Spinner color="primary" style={{ width: '5rem', height: '5rem' }} />
        </div>
      );
    }
    //Loading DONE
    else {
      return this.teamInfo();
    }
  }

  onSubmit = formValues => {
    //console.log('passed in ', formValues);
    const userObj = { ...this.props.team, ...formValues };
    //console.log('now contain ', userObj);
    this.props.editTeam(userObj, this.props.team.id);
  };

  componentDidMount() {
    // this.toggleSpinner();

    Promise.all([this.props.fetchCurrentUser(), this.props.fetchRoles()]).then(() => {
      console.log('param id: ', this.props.paramId);
      console.log('currentUser teamId: ', this.props.currentUser.teamId);
      this.setState({ userRole: this.props.roles[this.props.currentUser.roleId].name });
      Promise.all([
        this.props.fetchTeam(this.props.paramId),
        this.props.fetchUsers(),
        this.props.fetchCurrentTeam(this.props.currentUser.teamId),
      ])
        .then(() => {
          this.toggleSpinner();
        })
        .catch(() => {
          this.toggleSpinner();
        });
    });
  }

  kickMember(user) {
    const teamId = { teamId: null, isFreeAgent: true };
    const kickUser = { ...user, ...teamId };
    this.props.editUser(kickUser, user.id);
    this.props.fetchTeam(this.props.currentUser.teamId);
  }
  checkMember(user) {
    if (user.id !== this.props.currentUser.id) {
      return <Button onClick={() => this.kickMember(user)}> Kick </Button>;
    }
  }

  //TODO SHOW POINTS
  showTeamMembers() {
    var users = this.props.users
      .filter(user => {
        return user.teamId === this.props.team.id;
      })
      .map(teamate => {
        return (
          <tr key={teamate.id}>
            <td>
              {teamate.fname} {teamate.lname}
            </td>
            <td> </td>
            <td>{this.checkMember(teamate)}</td>
          </tr>
        );
      });
    return users;
  }

  teamInfo() {
    return (
      <div>
        <TitleForm initialValues={_.pick(this.props.team, 'name')} onSubmit={this.onSubmit} title="Team Name: " />
        <DescriptionForm initialValues={_.pick(this.props.team, 'description')} onSubmit={this.onSubmit} />
        <div>
          <h4>Members:</h4>
          <Table striped>
            <thead>
              <tr>
                <th>Names</th>
                <th>Scores</th>
              </tr>
            </thead>
            <tbody>{this.showTeamMembers()}</tbody>
          </Table>
        </div>
        <Link to="/free_agents">
          <Button size="lg" color="primary">
            Find Free Agents
          </Button>
        </Link>
      </div>
    );
  }

  render() {
    return this.loading();
  }
}

const mapStateToProps = (state, ownProps) => {
  //console.log(ownProps);

  return {
    currentUser: state.currentUser,
    team: state.team[ownProps.paramId],
    users: Object.values(state.users),
    roles: state.roles,
    currentTeam: state.currentTeam,
  };
};

export default connect(
  mapStateToProps,
  { fetchCurrentUser, fetchTeam, editTeam, fetchUsers, fetchRoles, fetchCurrentTeam, editUser }
)(TeamAdminView);