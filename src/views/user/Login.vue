<template>
  <div class="main">
    <a-form :form="form" class="user-layout-login" ref="formLogin" id="formLogin">

      <a-form-item>
        <a-input
          size="large"
          v-decorator="['username',validatorRules.username,{ validator: this.handleUsernameOrEmail }]"
          type="text"
          placeholder="請輸入帳戶名 / admin">
          <a-icon slot="prefix" type="user" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-form-item>
        <a-input
          v-decorator="['password',validatorRules.password]"
          size="large"
          type="password"
          autocomplete="false"
          placeholder="密碼 / 123456">
          <a-icon slot="prefix" type="lock" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-row :gutter="0">
        <a-col :span="16">
          <a-form-item>
            <a-input
              v-decorator="['inputCode',validatorRules.inputCode]"
              size="large"
              type="text"
              @change="inputCodeChange"
              placeholder="請輸入驗證碼">
              <a-icon slot="prefix" type="smile" :style="{ color: 'rgba(0,0,0,.25)' }"/>
            </a-input>
          </a-form-item>
        </a-col>
        <a-col :span="8" style="text-align: right">
          <img v-if="requestCodeSuccess" style="margin-top: 2px;" :src="randCodeImage" @click="handleChangeCheckCode"/>
          <img v-else style="margin-top: 2px;" src="../../assets/checkcode.png" @click="handleChangeCheckCode"/>
        </a-col>
      </a-row>



      <a-form-item style="margin-top:24px">
        <a-button
          size="large"
          type="primary"
          htmlType="submit"
          class="login-button"
          :loading="loginBtn"
          @click.stop.prevent="handleSubmit"
          :disabled="loginBtn">確定
        </a-button>
      </a-form-item>
    </a-form>

    <two-step-captcha
      v-if="requiredTwoStepCaptcha"
      :visible="stepCaptchaVisible"
      @success="stepCaptchaSuccess"
      @cancel="stepCaptchaCancel"></two-step-captcha>
    <login-select-tenant ref="loginSelect" @success="loginSelectOk"></login-select-tenant>
    <!-- <third-login ref="thirdLogin"></third-login>-->
  </div>
</template>

<script>
  //import md5 from "md5"
  import api from '@/api'
  import TwoStepCaptcha from '@/components/tools/TwoStepCaptcha'
  import { mapActions } from "vuex"
  import { timeFix } from "@/utils/util"
  import Vue from 'vue'
  import { ACCESS_TOKEN ,ENCRYPTED_STRING} from "@/store/mutation-types"
  import { putAction,postAction,getAction } from '@/api/manage'
  import { encryption , getEncryptedString } from '@/utils/encryption/aesEncrypt'
  import store from '@/store/'
  import { USER_INFO } from "@/store/mutation-types"
  import ThirdLogin from './third/ThirdLogin'
  import LoginSelectTenant from "./LoginSelectTenant";
  export default {
    components: {
      LoginSelectTenant,
      TwoStepCaptcha,
      ThirdLogin
    },
    data () {
      return {
        customActiveKey: "tab1",
        loginBtn: false,
        // login type: 0 email, 1 username, 2 telephone
        loginType: 0,
        requiredTwoStepCaptcha: false,
        stepCaptchaVisible: false,
        form: this.$form.createForm(this),
        encryptedString:{
          key:"",
          iv:"",
        },
        state: {
          time: 60,
          smsSendBtn: false,
        },
        validatorRules:{
          username:{rules: [{ required: true, message: '請輸入用戶名!'},{validator: this.handleUsernameOrEmail}]},
          password:{rules: [{ required: true, message: '請輸入密碼!',validator: 'click'}]},
          mobile:{rules: [{validator:this.validateMobile}]},
          captcha:{rule: [{ required: true, message: '請輸入驗證碼!'}]},
          inputCode:{rules: [{ required: true, message: '請輸入驗證碼!'}]}
        },
        verifiedCode:"",
        inputCodeContent:"",
        inputCodeNull:true,
        currentUsername:"",
        currdatetime:'',
        randCodeImage:'',
        requestCodeSuccess:false,
        message:''
      }
    },
    created () {
      this.currdatetime = new Date().getTime();
      Vue.ls.remove(ACCESS_TOKEN)
      this.getRouterData();
      this.handleChangeCheckCode();
      // update-begin- --- author:scott ------ date:20190805 ---- for:密碼加密邏輯暫時註釋掉，有點問題
      //this.getEncrypte();
      // update-end- --- author:scott ------ date:20190805 ---- for:密碼加密邏輯暫時註釋掉，有點問題
    },
    methods: {
      ...mapActions(['Login', 'Logout', 'PhoneLogin']),
      // handler
      handleUsernameOrEmail (rule, value, callback) {
        const regex = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
        if (regex.test(value)) {
          this.loginType = 0
        } else {
          this.loginType = 1
        }
        callback()
      },
      handleTabClick (key) {
        this.customActiveKey = key
        // this.form.resetFields()
      },
      handleSubmit () {
        let that = this
        let loginParams = {};
        that.loginBtn = true;
        // 使用帳戶密碼登錄
        if (that.customActiveKey === 'tab1') {
          that.form.validateFields([ 'username', 'password','inputCode', 'rememberMe' ], { force: true }, (err, values) => {
            if (!err) {
              loginParams.username = values.username
              // update-begin- --- author:scott ------ date:20190805 ---- for:密碼加密邏輯暫時註釋掉，有點問題
              //loginParams.password = md5(values.password)
              //loginParams.password = encryption(values.password,that.encryptedString.key,that.encryptedString.iv)
              loginParams.password = values.password
              loginParams.remember_me = values.rememberMe
              // update-begin- --- author:scott ------ date:20190805 ---- for:密碼加密邏輯暫時註釋掉，有點問題
              loginParams.captcha = that.message
              loginParams.checkKey = that.currdatetime
              console.log("登錄參數",loginParams)
              that.Login(loginParams).then((res) => {
                this.$refs.loginSelect.show(res.result)
              }).catch((err) => {
                that.requestFailed(err);
              });


            }else {
              that.loginBtn = false;
            }
          })
          // 使用手機號登錄
        } else {
          that.form.validateFields([ 'mobile', 'captcha', 'rememberMe' ], { force: true }, (err, values) => {
            if (!err) {
              loginParams.mobile = values.mobile
              loginParams.captcha = values.captcha
              loginParams.remember_me = values.rememberMe
              that.PhoneLogin(loginParams).then((res) => {
                console.log(res.result);
                this.$refs.loginSelect.show(res.result)
              }).catch((err) => {
                that.requestFailed(err);
              })

            }
          })
        }
      },
      getCaptcha (e) {
        e.preventDefault();
        let that = this;
        this.form.validateFields([ 'mobile' ], { force: true },(err,values) => {
            if(!values.mobile){
              that.cmsFailed("請輸入手機號");
            }else if (!err) {
              this.state.smsSendBtn = true;
              let interval = window.setInterval(() => {
                if (that.state.time-- <= 0) {
                  that.state.time = 60;
                  that.state.smsSendBtn = false;
                  window.clearInterval(interval);
                }
              }, 1000);

              const hide = this.$message.loading('驗證碼發送中..', 0);
              let smsParams = {};
              smsParams.mobile=values.mobile;
              smsParams.smsmode="0";
              postAction("/sys/sms",smsParams)
                .then(res => {
                  if(!res.success){
                    setTimeout(hide, 0);
                    this.cmsFailed(res.message);
                  }
                  console.log(res);
                  setTimeout(hide, 500);
                })
                .catch(err => {
                  setTimeout(hide, 1);
                  clearInterval(interval);
                  that.state.time = 60;
                  that.state.smsSendBtn = false;
                  this.requestFailed(err);
                });
            }
          }
        );
      },
      stepCaptchaSuccess () {
        this.loginSuccess()
      },
      stepCaptchaCancel () {
        this.Logout().then(() => {
          this.loginBtn = false
          this.stepCaptchaVisible = false
        })
      },
      handleChangeCheckCode(){
        var that = this;
        this.currdatetime = new Date().getTime();
        getAction(`/sys/randomImage/${this.currdatetime}`).then(res=>{
          if(res.success){
            this.randCodeImage = res.result
            that.message = res.message
            this.form.setFieldsValue({
              'username':'admin',
              'password':'123456',
              'inputCode':that.message
            })

            this.requestCodeSuccess=true
          }else{
            this.$message.error(res.message)
            this.requestCodeSuccess=false
          }
        }).catch(()=>{
          this.requestCodeSuccess=false
        })
      },
      loginSuccess () {
        this.$router.push({ path: "/dashboard/analysis" }).catch(()=>{
          console.log('登錄跳轉首頁出錯,這個錯誤從哪裡來的')
        })
        this.$notification.success({
          message: '歡迎',
          description: `${timeFix()}，歡迎回來`,
        });
      },
      cmsFailed(err){
        this.$notification[ 'error' ]({
          message: "登錄失敗",
          description:err,
          duration: 4,
        });
      },
      requestFailed (err) {
        this.$notification[ 'error' ]({
          message: '登錄失敗',
          description: ((err.response || {}).data || {}).message || err.message || "請求出現錯誤，請稍後再試",
          duration: 4,
        });
        this.loginBtn = false;
      },
      validateMobile(rule,value,callback){
        if (!value || new RegExp(/^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$/).test(value)){
          callback();
        }else{
          callback("您的手機號碼格式不正確!");
        }

      },
      validateInputCode(rule,value,callback){
        if(!value || this.verifiedCode==this.inputCodeContent){
          callback();
        }else{
          callback("您輸入的驗證碼不正確!");
        }
      },
      generateCode(value){
        this.verifiedCode = value.toLowerCase()
      },
      inputCodeChange(e){
        this.inputCodeContent = e.target.value
      },
      loginSelectOk(){
        this.loginSuccess()
      },
      getRouterData(){
        this.$nextTick(() => {
          if (this.$route.params.username) {
            this.form.setFieldsValue({
              'username': this.$route.params.username
            });
          }
        })
      },
      //獲取密碼加密規則
      getEncrypte(){
        var encryptedString = Vue.ls.get(ENCRYPTED_STRING);
        if(encryptedString == null){
          getEncryptedString().then((data) => {
            this.encryptedString = data
          });
        }else{
          this.encryptedString = encryptedString;
        }
      },
    }
  }
</script>

<style lang="less" scoped>

  .user-layout-login {
    label {
      font-size: 14px;
    }

    .getCaptcha {
      display: block;
      width: 100%;
      height: 40px;
    }

    .forge-password {
      font-size: 14px;
    }

    button.login-button {
      padding: 0 15px;
      font-size: 16px;
      height: 40px;
      width: 100%;
    }

    .user-login-other {
      text-align: left;
      margin-top: 24px;
      line-height: 22px;

      .item-icon {
        font-size: 24px;
        color: rgba(0,0,0,.2);
        margin-left: 16px;
        vertical-align: middle;
        cursor: pointer;
        transition: color .3s;

        &:hover {
          color: #1890ff;
        }
      }

      .register {
        float: right;
      }
    }
  }

</style>
<style>
  .valid-error .ant-select-selection__placeholder{
    color: #f5222d;
  }
</style>