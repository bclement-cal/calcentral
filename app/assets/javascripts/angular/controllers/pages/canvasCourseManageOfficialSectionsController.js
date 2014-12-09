/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Manage Official Sections LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseManageOfficialSectionsController', function(apiService, canvasCourseProvisionFactory, $scope) {
    apiService.util.setTitle('Manage Official Sections');

    var initState = function() {
      $scope.tabs = {
        existing: true,
        available: false
      };
    };

    $scope.showTab = function(requestedTabName) {
      angular.forEach($scope.tabs, function(tabStatus, tabName) {
        $scope.tabs[tabName] = (tabName === requestedTabName);
      });
    };

    $scope.fetchFeed = function() {
      $scope.isLoading = true;

      var feedRequestOptions = {
        isAdmin: false,
        adminMode: false,
        adminActingAs: false,
        adminByCcns: [],
        currentAdminSemester: false
      };
      canvasCourseProvisionFactory.getSections(feedRequestOptions).then(function(sectionsFeed) {
        if (sectionsFeed.status !== 200) {
          $scope.isLoading = false;
          $scope.feedFetchError = true;
        } else {
          if (sectionsFeed.data) {
            angular.extend($scope, sectionsFeed.data);
            $scope.isCourseCreator = $scope.is_admin || $scope.classCount > 0;
            $scope.feedFetched = true;
          }
        }
      });
    };

    // Wait until user profile is fully loaded before fetching section feed
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        initState();
        $scope.fetchFeed();
      }
    });
  });
})(window.angular);