import React, { Component } from 'react';
import './css/App.css';
import {Navbar, NavItem } from 'react-materialize';

class App extends Component {
  render() {
    return (
      <div>
        <head>
          <link rel="stylesheet" href="http://fonts.googleapis.com/icon?family=Material+Icons"></link>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.98.0/css/materialize.min.css"></link>
        </head>
        <body>
          <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.98.0/js/materialize.min.js"></script>
        </body>
        <div className="App">
          <nav>
            <div className="nav-wrapper">
              <Navbar brand='WalkSafe'>
                <NavItem href='map.html'>Map</NavItem>
                <NavItem href='explain.html'>Explain</NavItem>
                <NavItem href='about.html'>About</NavItem>
              </Navbar>
            </div>
          </nav>
        </div>
      </div>
    );
  }
}

export default App;
