<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="证书名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="subject">
              <a-input v-model="model.subject" placeholder="请输入证书名称"  ></a-input>
            </a-form-model-item>
          </a-col>
          <!--<a-col :span="24">
            <a-form-model-item label="密钥别称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="privateAlias">
              <a-input v-model="model.privateAlias" placeholder="请输入密钥别称"  ></a-input>
            </a-form-model-item>
          </a-col>-->
        <!--  <a-col :span="24">
            <a-form-model-item label="密钥密码" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="keyPass">
              <a-input v-model="model.keyPass" placeholder="请输入密钥密码"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="访问秘钥库的密码" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="storePass">
              <a-input v-model="model.storePass" placeholder="请输入访问秘钥库的密码"  ></a-input>
            </a-form-model-item>
          </a-col>-->
          <!--<a-col :span="24">
            <a-form-model-item label="证书生成路径" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="licensePath">
              <a-input v-model="model.licensePath" placeholder="请输入证书生成路径"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="密钥库存储路径" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="privateKeysStorePath">
              <a-input v-model="model.privateKeysStorePath" placeholder="请输入密钥库存储路径"  ></a-input>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24">
            <a-form-model-item label="证书生效时间" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="issuedTime">
              <j-date placeholder="请选择证书生效时间" v-model="model.issuedTime" date-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="证书失效时间" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="expiryTime">
              <j-date placeholder="请选择证书失效时间" v-model="model.expiryTime" date-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="用户类型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="consumerType">
              <a-input v-model="model.consumerType" placeholder="请输入用户类型"  ></a-input>
            </a-form-model-item>
          </a-col>

          <a-col :span="24">
            <a-form-model-item label="IP地址" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="ipAddress">
              <a-input v-model="model.ipAddress" placeholder="用逗號分割輸入的ip"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="MAC地址" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="macAddress">
              <a-input v-model="model.macAddress" placeholder="用逗號分割MAC地址"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="CPU序列号" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="cpuSerial">
              <a-input v-model="model.cpuSerial" placeholder="請輸入CPU序列号"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="主板序列号" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="mainBoardSerial">
              <a-input v-model="model.mainBoardSerial" placeholder="請輸入主板序列号"  ></a-input>
            </a-form-model-item>
          </a-col>

          <a-col :span="24">
            <a-form-model-item label="舊ip地址" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="oldIpAddress">
              <a-input v-model="model.oldIpAddress" placeholder="请输入舊ip地址"  ></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述信息" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="description">
              <a-textarea v-model="model.description" rows="4" placeholder="请输入描述信息" />
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'

  export default {
    name: 'SysLicenseForm',
    components: {
    },
    props: {
      //表单禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {
           subject: [
              { required: true, message: '请输入证书名称!'},
           ],
          privateAlias: [
              { required: true, message: '请输入密钥别称!'},
           ],
          keyPass: [
              { required: true, message: '请输入密钥密码!'},
           ],
          storePass: [
              { required: true, message: '请输入访问秘钥库的密码!'},
           ],
          issuedTime: [
            { required: true, message: '请选择证书生效时间!'},
          ],
          expiryTime: [
            { required: true, message: '请选择证书失效时间!'},
          ],
          ipAddress: [
            { required: true, message: '请输入ip地址!'},
          ],
          macAddress: [
            { required: true, message: '请输入MAC地址!'},
          ],
          cpuSerial: [
            { required: true, message: '请输入CPU序列号!'},
          ],
          mainBoardSerial: [
            { required: true, message: '请输入主板序列号!'},
          ],

        },
        url: {
          add: "/licensePackage/sysLicense/add",
          edit: "/licensePackage/sysLicense/edit",
          queryById: "/licensePackage/sysLicense/queryById"
        }
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //备份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      submitForm () {
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            let a = this.model;
            debugger
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
    }
  }
</script>