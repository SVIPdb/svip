import axios from 'axios'
import { serverURL } from '@/app_config'

export var HTTP = axios.create({ baseURL: serverURL })

HTTP.interceptors.response.use(function (response) {
	return response
}, function (error) {
	if (error.response.status === 501) return Promise.reject(error.response.data)
	else return Promise.reject(error)
})
