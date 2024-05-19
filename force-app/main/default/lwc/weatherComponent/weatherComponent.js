import { LightningElement, api, wire } from 'lwc';
import getWeatherDetails from '@salesforce/apex/WeatherService.getWeather';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';

import BILLING_CITY from '@salesforce/schema/Account.BillingCity';

const fields = [BILLING_CITY];

export default class WeatherScreen extends LightningElement {
    weatherData = {};
    showInfo = false;
    icon;
    @api recordId;


    @wire(getRecord, { recordId: '$recordId', fields: fields })
    account;

    @wire(getWeatherDetails, { city: '$billingCity'})
    wiredWeather({ error, data }) {
        if (data) {
            this.weatherData = data;
            this.icon = ' https://openweathermap.org/img/wn/'+ this.weatherData.icon + '@2x.png' 
            this.showInfo = true;
            console.log(data)

        } else if (error) {
            this.error = error.message;
            this.showInfo = false;
        }
    }

    get billingCity() {
        return getFieldValue(this.account.data, BILLING_CITY);
    }

    
}
