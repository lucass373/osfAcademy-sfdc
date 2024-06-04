import { LightningElement, api, wire } from 'lwc';
import getWeatherDetails from '@salesforce/apex/WeatherService.getWeather'; // Importing the Apex method for fetching weather details
import { getFieldValue, getRecord } from 'lightning/uiRecordApi'; // Importing functions for retrieving record data

import BILLING_CITY from '@salesforce/schema/Account.BillingCity'; // Importing the Billing City field from the Account object schema

const fields = [BILLING_CITY]; // Defining fields to retrieve from the record

export default class WeatherScreen extends LightningElement {
    @api recordId; // Record Id passed to the component
    weatherData = {}; // Object to store weather data
    showInfo = false; // Flag to control visibility of weather information
    icon; // Variable to store weather icon URL
    titleStr;

    // Wire service to get the record data
    @wire(getRecord, { recordId: '$recordId', fields: fields })
    account;

    // Wire service to call the Apex method for weather data
    @wire(getWeatherDetails, { city: '$billingCity'})
    wiredWeather({ error, data }) {
        if (data) {
            // If data is received, update weatherData, icon, and showInfo
            this.titleStr = "Weather in " + getFieldValue(this.account.data, BILLING_CITY);
            this.weatherData = data;
            this.icon = ' https://openweathermap.org/img/wn/'+ this.weatherData.icon + '@2x.png' 
            this.showInfo = true;

        } else if (error) {
            // If error occurs, handle it and set showInfo to false
            this.error = error.message;
            this.showInfo = false;
        }
    }

    // Getter function to retrieve Billing City from record data
    get billingCity() {
        return getFieldValue(this.account.data, BILLING_CITY);
    }
}