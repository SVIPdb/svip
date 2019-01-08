import Vue from 'vue'
import Vuex from 'vuex'
import users from './modules/users'
import genes from './modules/genes'

Vue.use(Vuex)


export default new Vuex.Store({
  modules: {
    users,
    genes
  }
})